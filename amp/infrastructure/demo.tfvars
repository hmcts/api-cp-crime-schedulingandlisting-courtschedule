api_mgmt_rg   = "rg-sps-platform-demo"
api_mgmt_name = "sps-api-mgmt-demo"

apim_product = {
  name                          = "cp-crime-schedulingandlisting"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

# Demo is external-entra-id's stg tenant, the one aat also uses, so the tenant and the
# own apply output rather than copied across from aat.tfvars.
entra_tenant_id = "db827888-77df-4707-b3d9-24a3dfe32889"
entra_client_id = "d6b20cca-b3dd-4232-9568-6d1313726bfa"

# service_host is sit, the non-live network - a demo audience sees no live CP
# data. aat's prp backend is on the live network, which is why demo does not follow it here.
apis = {
  courtschedule = {
    openapi_spec_path = "../../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "sitamp01-appgw.sit.nl.cjscp"
    service_path      = "/slc"
    revision          = "1"
    required_roles    = ["app.read"]
  }
}

# Token exchange is off here until the APIM identity and CP-access apps exist for this environment.
token_exchange = null
