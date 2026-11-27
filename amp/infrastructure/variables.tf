# ─── Variables injected automatically by the HMCTS GitHub Actions reusable workflow ───

variable "env" {
  type        = string
  description = "Environment name, injected by CI (e.g. sbox, dev, prod)."
  default     = ""
}

variable "product" {
  type        = string
  description = "Product name, injected by CI."
  default     = ""
}

variable "subscription" {
  type        = string
  description = "Azure subscription ID, injected by CI."
  default     = ""
}

variable "aks_subscription_id" {
  type        = string
  description = "AKS subscription ID, injected by CI."
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID, injected by CI."
  default     = ""
}

variable "builtFrom" {
  type        = string
  description = "Repository reference, injected by CI."
  default     = ""
}

variable "ci_service_principal_object_id" {
  type        = string
  description = "CI service principal object ID, injected by CI."
  default     = ""
}

# ─── Module-specific variables ───

variable "api_mgmt_rg" {
  type        = string
  description = "Resource group name of the target APIM instance."
}

variable "api_mgmt_name" {
  type        = string
  description = "Name of the target APIM instance."
}

variable "apim_product" {
  description = "Product configuration to create in APIM."
  type = object({
    name                          = string
    description                   = optional(string)
    subscription_required         = optional(bool, true)
    subscriptions_limit           = optional(number, 20)
    approval_required             = optional(bool, true)
    published                     = optional(bool, true)
    product_access_control_groups = optional(list(string), [])
  })
}

variable "entra_tenant_id" {
  type        = string
  description = "Entra tenant ID used in the product JWT validation policy."
}

variable "entra_client_id" {
  type        = string
  description = "Entra client ID (audience) used in the product JWT validation policy."
}

variable "apis" {
  description = "Map of APIs to register in APIM. Details are sourced from the referenced OpenAPI spec file."
  type = map(object({
    openapi_spec_path     = string
    service_host          = string
    service_path          = optional(string, "")
    name                  = optional(string)
    display_name          = optional(string)
    path                  = optional(string)
    revision              = optional(string, "1")
    protocols             = optional(list(string), ["https"])
    subscription_required = optional(bool, true)
    api_type              = optional(string, "http")
    # Entra app roles on hmcts-api-marketplace accepted for this API; a token needs any one of them.
    required_roles = optional(list(string), ["app.read"])
    # Adds Authorization and Accept header boxes to the portal's Try it (APIM import only).
    try_it_auth_headers = optional(bool, false)
    # Consumers that get an API-scoped APIM subscription; each key is stored in Key Vault.
    consumers = optional(list(string), [])
  }))

  validation {
    condition     = alltrue([for api in values(var.apis) : length(api.required_roles) > 0])
    error_message = "Each API must have at least one required_roles entry."
  }

  validation {
    condition = alltrue(flatten([
      for api_key, api in var.apis : [
        for consumer in api.consumers : can(regex("^[0-9A-Za-z-]{1,90}$", "${api_key}-${consumer}"))
      ]
    ]))
    error_message = "API keys and consumer names may only contain letters, digits and hyphens (used in Key Vault secret names)."
  }
}

variable "subscription_key_vault_name" {
  type        = string
  description = "Key Vault (in api_mgmt_rg) where API subscription keys are stored as secrets. Required when any API has consumers."
  default     = null

  validation {
    condition     = var.subscription_key_vault_name != null || alltrue([for api in values(var.apis) : length(api.consumers) == 0])
    error_message = "subscription_key_vault_name must be set when any API has consumers."
  }
}

variable "create_subscription_user" {
  type        = bool
  description = "Create the shared 'amp-subscriptions' APIM user that owns consumer subscriptions. Set true in exactly one repo per APIM instance; other repos look it up."
  default     = false
}

variable "entra_token_helper" {
  description = "Sandbox only. When set, publishes a portal API that swaps a client's own credentials for an Entra token. Leave unset in every other environment."
  type = object({
    # Application Insights logger whose body logging is switched off for that API.
    app_insights_logger_name = string
  })
  default = null
}

variable "token_exchange" {
  description = <<-EOT
    When set, the API policy includes APIM's shared token-exchange fragment (shared-platform-services-infra),
    which swaps the validated external token for a token from the backend's tenant before calling the backend.
    APIM's identity lives in that fragment; this API's tenant, audience and consumers are set here.
  EOT
  type = object({
    # Tenant that issues the backend token.
    tenant_id = string
    # Client ID of the backend API's app; the token is requested for "<audience>/.default".
    audience = string
    # This API's consumers: external client ID (the token's azp) => that consumer's backend-access app client ID.
    client_map = optional(map(string), {})
    # true: a consumer missing from client_map gets 403. false: its request is forwarded unchanged,
    # with the external token.
    reject_unmapped = optional(bool, false)
  })
  default = null

  validation {
    condition = var.token_exchange == null || alltrue(concat(
      [for id in [try(var.token_exchange.tenant_id, ""), try(var.token_exchange.audience, "")] : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))],
      [for k, v in try(var.token_exchange.client_map, {}) : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", k)) && can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", v))]
    ))
    error_message = "token_exchange tenant_id, audience and every client_map key and value must be lower-case GUIDs."
  }
}
