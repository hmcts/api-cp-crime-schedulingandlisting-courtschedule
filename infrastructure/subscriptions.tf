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
    "${pair.consumer}:${pair.api_key}" => pair
  }

  has_subscriptions = length(local.api_subscriptions) > 0

  environment = trimprefix(var.api_mgmt_name, "sps-api-mgmt-")

  subscription_user_id = local.has_subscriptions ? (
    var.create_subscription_user
    ? azurerm_api_management_user.shared_subscriptions[0].id
    : data.azurerm_api_management_user.shared_subscriptions[0].id
  ) : null
}

data "azurerm_api_management" "subscriptions" {
  count = local.has_subscriptions ? 1 : 0

  name                = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
}

data "azurerm_key_vault" "subscription_keys" {
  count = local.has_subscriptions ? 1 : 0

  name                = var.subscription_key_vault_name
  resource_group_name = var.api_mgmt_rg
}

resource "azurerm_api_management_user" "shared_subscriptions" {
  count = local.has_subscriptions && var.create_subscription_user ? 1 : 0

  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
  user_id             = "amp-subscriptions"
  first_name          = "AMP"
  last_name           = "Subscriptions"
  email               = "no-reply@hmcts.com"
  state               = "active"
}

data "azurerm_api_management_user" "shared_subscriptions" {
  count = local.has_subscriptions && !var.create_subscription_user ? 1 : 0

  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
  user_id             = "amp-subscriptions"
}

resource "azurerm_api_management_subscription" "api_subscriptions" {
  for_each = local.api_subscriptions

  api_management_name = var.api_mgmt_name
  resource_group_name = var.api_mgmt_rg
  display_name        = each.key
  api_id              = "${data.azurerm_api_management.subscriptions[0].id}/apis/${module.apis[each.value.api_key].name}"
  user_id             = local.subscription_user_id
  state               = "active"
  allow_tracing       = false

  depends_on = [azurerm_api_management_api_policy.api_policy]
}

resource "azurerm_key_vault_secret" "api_subscription_keys" {
  for_each = local.api_subscriptions

  # Colons are invalid in Key Vault secret names, so consumer:api becomes consumer-api.
  name         = "amp-apim-sub-${local.environment}-${replace(each.key, ":", "-")}-primary-key"
  value        = azurerm_api_management_subscription.api_subscriptions[each.key].primary_key
  key_vault_id = data.azurerm_key_vault.subscription_keys[0].id
  content_type = "APIM subscription key (Ocp-Apim-Subscription-Key) for ${each.value.consumer} on API ${each.value.api_key}"
}
