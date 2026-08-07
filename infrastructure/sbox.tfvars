api_mgmt_rg   = "rg-sps-platform-sbox"
api_mgmt_name = "sps-api-mgmt-sbox"

apim_product = {
  name                          = "cp-crime-schedulingandlisting"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "d44f885c-4fac-47bf-afde-d7d861ec4d7b"
entra_client_id = "472c23a2-9d6a-4a6e-8008-3eb08cef759c"

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    service_host      = "spnl-dev-apim-int-gw.dev.nl.cjscp"
    service_path      = "/amp/slc"
    revision          = "1"
  }
}
