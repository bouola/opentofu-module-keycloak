variable "keycloak_client_id" {
  type        = string
  description = "Keycloak client ID for authentication"
}

variable "keycloak_username" {
  type        = string
  description = "Keycloak admin username for authentication"
}

variable "keycloak_password" {
  type        = string
  description = "Keycloak admin password for authentication"
}

variable "keycloak_url" {
  type        = string
  description = "Base URL of the Keycloak server"
}

variable "keycloak_realm" {
  type = object({
    name                     = string
    display_name             = optional(string)
    default_email_domain     = string
    default_usergroups       = optional(list(string), [])
    login_theme              = optional(string, "keycloak.v2")
    login_with_email_allowed = optional(bool, true)
    access_code_lifespan     = optional(string, "1h")
    ssl_required             = optional(string, "external")
    password_policy          = optional(string, "upperCase(1) and length(10) and forceExpiredPasswordChange(365) and notUsername")
    internationalization     = optional(map(string), {})
    security_defenses        = optional(map(string), {})
  })
  description = "Keycloak realm configuration including name, display name, default email domain, and default user groups"
}

variable "keycloak_groups" {
  type = list(object({
    name        = string
    path        = optional(string, "") # Parent path like "/Organization/Engineering" (empty = root)
    roles       = optional(list(string), [])
    permissions = optional(list(map(string)), [])
    attributes  = optional(map(list(string)), {})
  }))
  description = "List of Keycloak groups with hierarchy and configuration"
}

variable "keycloak_users" {
  type = list(object({
    firstname      = string
    lastname       = string
    username       = optional(string, null)
    force_username = optional(bool, false)
    groups         = optional(list(string), [])
    roles          = optional(list(string), [])
    attributes     = optional(map(string), {})
    is_external    = optional(bool, false)
    enabled        = optional(bool, true)
  }))
  description = "List of users to create"
}

variable "keycloak_saml_clients" {
  type = list(object({
    name                       = string
    description                = optional(string)
    root_url                   = string
    base_url                   = string
    valid_redirect_uris        = optional(set(string))
    master_saml_processing_url = string
    name_id_format             = string
    include_authn_statement    = optional(bool, false)
    force_post_binding         = optional(bool, true)
    sign_documents             = optional(bool, false)
    sign_assertions            = optional(bool, false)
    signature_algorithm        = optional(string)
    front_channel_logout       = optional(bool, true)
    saml_attribute_mappers = optional(list(object({
      name                       = string
      user_attribute             = string
      saml_attribute_name        = string
      saml_attribute_name_format = optional(string, "Basic")
    })))
  }))
  default     = []
  description = "Keycloak SAML clients"
}

variable "keycloak_oidc_clients" {
  type = list(object({
    name                         = string
    enabled                      = optional(bool, true)
    description                  = optional(string, null)
    always_display_in_console    = optional(bool, null)
    access_type                  = optional(string, "CONFIDENTIAL")
    client_secret                = optional(string, null)
    standard_flow_enabled        = optional(bool, true)
    implicit_flow_enabled        = optional(bool, false)
    direct_access_grants_enabled = optional(bool, false)
    service_accounts_enabled     = optional(bool, false)
    authorization = optional(object({
      allow_remote_resource_management = optional(bool, true)
      decision_strategy                = optional(string, "UNANIMOUS")
      policy_enforcement_mode          = optional(string, "ENFORCING")
      keep_defaults                    = optional(bool, false)
    }), null)
    root_url                        = optional(string, null)
    admin_url                       = optional(string, null)
    base_url                        = optional(string, null)
    valid_redirect_uris             = optional(list(string), null)
    valid_post_logout_redirect_uris = optional(list(string), null)
    web_origins                     = optional(list(string), null)
    frontchannel_logout_enabled     = optional(bool, false)
    frontchannel_logout_url         = optional(string, null)

    oidc_group_membership_mappers = optional(list(object({
      name       = string
      claim_name = string
    })))
  }))
  default     = []
  description = "Keycloak OpenID Connect (OIDC) clients and their settings (flows, URLs, secrets, mappers, logout, web origins, etc.)"
}
