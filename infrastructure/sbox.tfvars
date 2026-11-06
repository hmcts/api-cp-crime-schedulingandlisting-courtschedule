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
entra_client_id = "30288840-e345-4543-99ee-f9253d789339"

# amp-api-try-slc, the resource app the Marketplace grants consumers app.read on in sbox
# (ENTRA_RESOURCE_APP_ID_SLC in service-api-marketplace). Accepting it lets their tokens work here.
additional_audiences = ["c4c8974c-2800-4fe6-964f-dcd4c0820507"]

apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "devamp01-appgw.dev.nl.cjscp"
    service_path      = "/slc"
    revision          = "1"
    required_roles    = ["app.read"]
    # Pre-filled Authorization and Accept boxes in the portal's Try it (see apis.tf).
    try_it_auth_headers = true
    # Answers from recorded scenarios instead of the backend, replacing Try It Now for slc.
    scenarios_file = "sandbox/courtschedule-scenarios.json"
    # The Marketplace issues sbox keys on this product, so they work here too.
    additional_products = ["try-it-now-cp-crime-schedulingandlisting"]
  }
}

# Lets clients get a token with their own credentials in the sandbox portal (see entra-token.tf).
entra_token_helper = {
  app_insights_logger_name = "sps-api-mgmt-sbox-logger"
  # Tokens for amp-api-try-slc, the app consumers hold a role on (see additional_audiences).
  default_scope_client_id = "c4c8974c-2800-4fe6-964f-dcd4c0820507"
}
