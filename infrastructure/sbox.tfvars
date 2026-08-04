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

entra_tenant_id = "e2995d11-9947-4e78-9de6-d44e0603518e"
entra_client_id = "b69a4519-354b-481b-88a5-65ab7c83273e"

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    service_host      = "spnl-dev-apim-int-gw.dev.nl.cjscp"
    service_path      = "/amp/slc"
    revision          = "1"
  }
}
