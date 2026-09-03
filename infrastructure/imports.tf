import {
  for_each = var.api_mgmt_name == "sps-api-mgmt-preview" ? toset(["administrators"]) : toset([])
  to       = module.product.azurerm_api_management_product_group.access_control_groups[each.value]
  id       = "/subscriptions/7cfd7e05-06a1-4d9b-a426-db304bc99aab/resourceGroups/rg-sps-platform-preview/providers/Microsoft.ApiManagement/service/sps-api-mgmt-preview/products/cp-crime-schedulingandlisting/groups/administrators"
}
