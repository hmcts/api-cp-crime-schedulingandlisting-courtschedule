locals {
  api_specs = {
    for api_key, api in var.apis :
    api_key => yamldecode(file(api.openapi_spec_path))
  }

  # Declared only in the copy imported into APIM, so the portal's Try it shows them as
  # pre-filled boxes. The spec itself is untouched: header parameters there would change
  # the generated interface the service implements.
  try_it_headers = [
    {
      name        = "Authorization"
      in          = "header"
      required    = true
      description = "Bearer token from Get an Entra access token (sandbox)."
      schema      = { type = "string", default = "Bearer <access_token>" }
    },
    {
      name     = "Accept"
      in       = "header"
      required = false
      schema   = { type = "string", default = "application/json" }
    },
  ]

  http_methods = ["get", "put", "post", "delete", "patch", "head", "options"]

  # Sandbox only: the recorded scenarios an API answers from instead of its backend.
  scenarios = {
    for api_key, api in var.apis :
    api_key => jsondecode(file(api.scenarios_file)) if api.scenarios_file != null
  }

  # What the portal shows for them: the first scenario's value pre-filled in Try it, and every
  # scenario listed in the operation description, as GET /scenarios did on Try It Now.
  scenario_parameter = { for api_key, api in var.apis : api_key => try(local.scenarios[api_key].parameter, "") }
  scenario_default   = { for api_key, api in var.apis : api_key => try(local.scenarios[api_key].scenarios[0].value, "") }
  scenario_notes = {
    for api_key, file in local.scenarios : api_key => join("\n", concat(
      [
        "",
        "",
        "**Sandbox:** this API answers with recorded examples. It does not call Common Platform and holds no real case data. Use one of these values for `${file.parameter}`:",
        "",
        "| `${file.parameter}` | Status | What you get |",
        "| --- | --- | --- |",
      ],
      [for scenario in file.scenarios : "| `${scenario.value}` | ${scenario.status} | ${scenario.summary} |"],
      ["", "Any other value gets the `${file.unmatched}` response."]
    ))
  }

  # Declared only in the copy imported into APIM. The spec itself is untouched.
  import_specs = {
    for api_key, api in var.apis :
    api_key => api.try_it_auth_headers || api.scenarios_file != null ? yamlencode(merge(local.api_specs[api_key], {
      paths = {
        for path, item in local.api_specs[api_key].paths : path => merge(
          { for key, value in item : key => value if !contains(local.http_methods, key) },
          {
            for method, operation in item : method => merge(operation, {
              parameters = concat(
                [
                  for parameter in try(operation.parameters, []) : merge(parameter, {
                    schema = merge(try(parameter.schema, {}), (
                      parameter.in == "path" && parameter.name == local.scenario_parameter[api_key]
                      ? { default = local.scenario_default[api_key] } : {}
                    ))
                  })
                ],
                [for header in local.try_it_headers : header if api.try_it_auth_headers]
              )
              description = "${try(operation.description, "")}${try(local.scenario_notes[api_key], "")}"
            }) if contains(local.http_methods, method)
          }
        )
      }
    })) : file(api.openapi_spec_path)
  }

  # (API, product) pairs for additional_products.
  additional_product_apis = {
    for pair in flatten([
      for api_key, api in var.apis : [
        for product in api.additional_products : { api_key = api_key, product = product }
      ]
    ]) : "${pair.api_key}/${pair.product}" => pair
  }
}

module "apis" {
  for_each = var.apis

  source = "git::https://github.com/hmcts/cnp-module-api-mgmt-api.git?ref=master"

  api_mgmt_rg   = var.api_mgmt_rg
  api_mgmt_name = var.api_mgmt_name
  product_id    = module.product.product_id

  revision = each.value.revision

  display_name = coalesce(
    try(each.value.display_name, null),
    try(local.api_specs[each.key].info.title, null),
    each.key
  )

  name = coalesce(
    try(each.value.name, null),
    lower(replace(
      coalesce(
        try(local.api_specs[each.key].info.title, null),
        each.key
      ),
      "/[^0-9A-Za-z-]/",
      "-"
    ))
  )

  path = coalesce(
    try(each.value.path, null),
    lower(replace(each.key, "/[^0-9A-Za-z-]/", "-"))
  )

  api_description = try(local.api_specs[each.key].info.description, null)

  protocols             = each.value.protocols
  service_url           = "https://${each.value.service_host}.org.uk${each.value.service_path}"
  subscription_required = each.value.subscription_required
  api_type              = each.value.api_type

  swagger_url    = local.import_specs[each.key]
  content_format = "openapi"
}

# With a scenarios file (sandbox only) the policy answers from the recorded scenarios, picked by
# the named path parameter ignoring case, and never calls the backend. The token is still checked
# first: 401 when it is missing or invalid, 403 when it is valid but has none of required_roles.
# Without one the policy is as before: a token without the role is a 401, then the backend.
resource "azurerm_api_management_api_policy" "api_policy" {
  for_each = var.apis

  api_name            = module.apis[each.key].name
  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg

  xml_content = templatefile("${path.module}/policies/api-policy.xml", {
    tenant_id      = var.entra_tenant_id
    audiences      = concat([var.entra_client_id], var.additional_audiences)
    required_roles = each.value.required_roles
    parameter      = local.scenario_parameter[each.key]
    scenarios      = try(local.scenarios[each.key].scenarios, [])
    unmatched      = try(one([for s in local.scenarios[each.key].scenarios : s if s.value == local.scenarios[each.key].unmatched]), null)
  })

  lifecycle {
    precondition {
      condition = try(alltrue(concat(
        [contains([for s in local.scenarios[each.key].scenarios : s.value], local.scenarios[each.key].unmatched)],
        [for s in local.scenarios[each.key].scenarios : can(regex("^[A-Za-z0-9-]+$", s.value))],
        [can(regex("^[a-z_]+$", local.scenarios[each.key].parameter))]
      )), each.value.scenarios_file == null)
      error_message = "A scenarios file needs a parameter name, letters, digits and hyphens in every value, and an unmatched value that is one of its scenarios."
    }
  }

  depends_on = [module.apis]
}

# Lets keys from other products call the API, e.g. the sandbox Try It Now product whose
# subscriptions the Marketplace issues.
resource "azurerm_api_management_product_api" "additional" {
  for_each = local.additional_product_apis

  api_name            = module.apis[each.value.api_key].name
  product_id          = each.value.product
  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
}
