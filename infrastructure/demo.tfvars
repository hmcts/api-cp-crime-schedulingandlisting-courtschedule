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
# hmcts-api-marketplace resource app are the same pair aat names. Both are read from that tenant's
# own apply output rather than copied across from aat.tfvars.
entra_tenant_id = "db827888-77df-4707-b3d9-24a3dfe32889"
entra_client_id = "26b2922f-61a8-4cee-b4ba-d0d7aba215ad"

# service_host is sit, the non-live network - a demo audience sees no live CP
# data. aat's prp backend is on the live network, which is why demo does not follow it here.
apis = {
  courtschedule = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Scheduling and Listing Schedule API (slc)"
    path              = "amp/slc"
    service_host      = "sitamp01-appgw.sit.nl.cjscp"
    service_path      = "/slc"
    revision          = "1"
    required_roles    = ["app.read"]
  }
}
