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
  description = "Key Vault (in api_mgmt_rg) where API subscription keys are stored as secrets."
}
