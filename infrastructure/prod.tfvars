api_mgmt_rg   = "rg-sps-platform-prod"
api_mgmt_name = "sps-api-mgmt-prod"

apim_product = {
  name                          = "cp-crime-schedulingandlisting"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "0d0315f6-3c04-4edb-ac37-b05f580cc122"
entra_client_id = "7d4eb263-0332-420a-8beb-a3cd5cc64b92"

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "prdamp01-appgw.prd.lv.cjscp"
    service_path      = "/slc"
    revision          = "1"
  }
}
