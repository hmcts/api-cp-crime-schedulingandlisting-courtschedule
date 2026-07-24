locals {
  api_specs = {
    for api_key, api in var.apis :
    api_key => yamldecode(file(api.openapi_spec_path))
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

  protocols             = each.value.protocols
  service_url           = var.service_url
  subscription_required = each.value.subscription_required
  api_type              = each.value.api_type

  swagger_url    = file(each.value.openapi_spec_path)
  content_format = "openapi"
}
