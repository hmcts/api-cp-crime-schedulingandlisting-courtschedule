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

# Same stg tenant and audience the SIT /slc pod trusts, so a token APIM accepts also passes the pod.
entra_tenant_id = "db827888-77df-4707-b3d9-24a3dfe32889"
entra_client_id = "26b2922f-61a8-4cee-b4ba-d0d7aba215ad"

# Tests the new SIT private endpoint, which reaches the /slc pod on the oauth gateway.
apis = {
  courtschedule = {
    openapi_spec_path = "../../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "ccp-marketplace.sit.nl.cjscp"
    service_path      = "/slc"
    revision          = "1"
    required_roles    = ["app.read"]
  }
}

# Connectivity test only: no CP token exchange.
cp_token_exchange = null
