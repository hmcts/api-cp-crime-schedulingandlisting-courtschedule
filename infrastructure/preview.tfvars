api_mgmt_rg   = "rg-sps-platform-preview"
api_mgmt_name = "sps-api-mgmt-preview"

apim_product = {
  name                          = "cp-crime-schedulingandlisting"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "d44f885c-4fac-47bf-afde-d7d861ec4d7b"
entra_client_id = "30288840-e345-4543-99ee-f9253d789339"

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "devamp01-appgw.dev.nl.cjscp"
    service_path      = "/slc"
    revision          = "1"
  }
}
