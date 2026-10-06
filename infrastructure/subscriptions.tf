# API-scoped APIM subscriptions, one per consumer listed in var.apis[*].consumers.
# Each primary key is stored in Key Vault so it can be shared with the consumer
# (e.g. via the developer portal) without giving them access to APIM.
locals {
  api_subscriptions = {
    for pair in flatten([
      for api_key, api in var.apis : [
        for consumer in api.consumers : {
          api_key  = api_key
          consumer = consumer
        }
      ]
    ]) :
    "${pair.api_key}-${pair.consumer}" => pair
  }
}

data "azurerm_api_management" "apim" {
  name                = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
}

data "azurerm_key_vault" "subscription_keys" {
  name                = var.subscription_key_vault_name
  resource_group_name = var.api_mgmt_rg
}

resource "azurerm_api_management_subscription" "api_subscriptions" {
  for_each = local.api_subscriptions

  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
  display_name        = "${each.value.consumer} (${each.value.api_key})"
  api_id              = "${data.azurerm_api_management.apim.id}/apis/${module.apis[each.value.api_key].name}"
  state               = "active"
  allow_tracing       = false
}

resource "azurerm_key_vault_secret" "api_subscription_keys" {
  for_each = local.api_subscriptions

  name         = "apim-sub-${each.key}"
  value        = azurerm_api_management_subscription.api_subscriptions[each.key].primary_key
  key_vault_id = data.azurerm_key_vault.subscription_keys.id
  content_type = "APIM subscription key (Ocp-Apim-Subscription-Key) for ${each.value.consumer} on API ${each.value.api_key}"
}
