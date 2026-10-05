api_mgmt_rg   = "rg-sps-platform-aat"
api_mgmt_name = "sps-api-mgmt-aat"

apim_product = {
  name                          = "cp-crime-schedulingandlisting"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "db827888-77df-4707-b3d9-24a3dfe32889"
entra_client_id = "26b2922f-61a8-4cee-b4ba-d0d7aba215ad"

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "prpamp01-appgw.prp.lv.cjscp"
    service_path      = "/slc"
    revision          = "1"
  }
}
