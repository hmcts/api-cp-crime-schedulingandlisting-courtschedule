# APIM automatically adds the administrators group to new products, so import it
# into state instead of creating it. Not needed for sbox, which already manages it.
locals {
  administrators_product_group_ids = {
    "sps-api-mgmt-preview" = "/subscriptions/7cfd7e05-06a1-4d9b-a426-db304bc99aab/resourceGroups/rg-sps-platform-preview/providers/Microsoft.ApiManagement/service/sps-api-mgmt-preview/products/cp-crime-schedulingandlisting/groups/administrators"
    "sps-api-mgmt-aat"     = "/subscriptions/70bea6e3-384f-4cf4-b551-743a78d716cd/resourceGroups/rg-sps-platform-aat/providers/Microsoft.ApiManagement/service/sps-api-mgmt-aat/products/cp-crime-schedulingandlisting/groups/administrators"
    "sps-api-mgmt-prod"    = "/subscriptions/890625e2-7a8b-445c-81b4-8044a062cef3/resourceGroups/rg-sps-platform-prod/providers/Microsoft.ApiManagement/service/sps-api-mgmt-prod/products/cp-crime-schedulingandlisting/groups/administrators"
  }
}

import {
  for_each = contains(keys(local.administrators_product_group_ids), var.api_mgmt_name) ? toset(["administrators"]) : toset([])
  to       = module.product.azurerm_api_management_product_group.access_control_groups[each.value]
  id       = local.administrators_product_group_ids[var.api_mgmt_name]
}
