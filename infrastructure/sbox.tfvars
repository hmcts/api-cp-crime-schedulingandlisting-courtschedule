api_mgmt_rg   = "rg-sps-platform-sbox"
api_mgmt_name = "sps-api-mgmt-sbox"
service_host  = "devamp01.ingress01.dev.nl.cjscp.org.uk"

apim_product = {
  name                          = "cp-crime-schedulingandlisting"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators"]
  product_policy                = ""
}

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    revision          = "1"
  }
}
