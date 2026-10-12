# Sandbox only: a "Get an Entra access token" API in the developer portal, so clients can
# swap their own client credentials for a token and try the Court Schedule API there.
# Created only when entra_token_helper is set in the environment's tfvars.
locals {
  entra_token_enabled = var.entra_token_helper != null
  entra_token_spec    = yamldecode(file("${path.module}/entra-token/openapi.yml"))
}

data "azurerm_api_management" "apim" {
  count = local.entra_token_enabled ? 1 : 0

  name                = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
}

resource "azurerm_api_management_api" "entra_token" {
  count = local.entra_token_enabled ? 1 : 0

  name                = "slc-entra-token"
  resource_group_name = var.api_mgmt_rg
  api_management_name = var.api_mgmt_name
  revision            = "1"

  display_name = local.entra_token_spec.info.title
  # Trimmed: a YAML block scalar ends in a newline, which APIM would keep.
  description           = trimspace(local.entra_token_spec.info.description)
  path                  = "amp/slc-token"
  protocols             = ["https"]
  service_url           = "https://login.microsoftonline.com/${var.entra_tenant_id}/oauth2/v2.0"
  subscription_required = true

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/entra-token/openapi.yml")
  }
}

# Same product as the Court Schedule API, so the subscription key a client already has works.
resource "azurerm_api_management_product_api" "entra_token" {
  count = local.entra_token_enabled ? 1 : 0

  api_name            = azurerm_api_management_api.entra_token[0].name
  product_id          = module.product.product_id
  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
}

resource "azurerm_api_management_api_policy" "entra_token" {
  count = local.entra_token_enabled ? 1 : 0

  api_name            = azurerm_api_management_api.entra_token[0].name
  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg

  xml_content = templatefile("${path.module}/policies/entra-token-policy.xml", {
    default_scope = "${var.entra_client_id}/.default"
  })
}

# The service-wide Application Insights diagnostic logs request and response bodies. This
# API's bodies carry client secrets and access tokens, so its own diagnostic logs none.
resource "azurerm_api_management_api_diagnostic" "entra_token" {
  count = local.entra_token_enabled ? 1 : 0

  identifier               = "applicationinsights"
  api_name                 = azurerm_api_management_api.entra_token[0].name
  api_management_name      = var.api_mgmt_name
  resource_group_name      = var.api_mgmt_rg
  api_management_logger_id = "${data.azurerm_api_management.apim[0].id}/loggers/${var.entra_token_helper.app_insights_logger_name}"

  sampling_percentage = 100
  always_log_errors   = true
  verbosity           = "information"

  frontend_request {
    body_bytes = 0
  }
  frontend_response {
    body_bytes = 0
  }
  backend_request {
    body_bytes = 0
  }
  backend_response {
    body_bytes = 0
  }
}
