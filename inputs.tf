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
    default_email_domain     = optional(string) # Required only when keycloak_users is managed by this module
    default_usergroups       = optional(list(string), [])
    login_theme              = optional(string, "keycloak.v2")
    email_theme              = optional(string)
    login_with_email_allowed = optional(bool, true)
    access_code_lifespan     = optional(string, "1h")
    ssl_required             = optional(string, "external")
    password_policy          = optional(string, "upperCase(1) and length(10) and forceExpiredPasswordChange(365) and notUsername")

    # User self-service
    registration_allowed           = optional(bool, false)
    registration_email_as_username = optional(bool, false)
    edit_username_allowed          = optional(bool, false)
    duplicate_emails_allowed       = optional(bool, false)
    verify_email                   = optional(bool, false)
    reset_password_allowed         = optional(bool, false)

    internationalization = optional(object({
      supported_locales = optional(list(string), ["en", "fr"])
      default_locale    = optional(string, "en")
    }), {})
    security_defenses = optional(object({
      # Brute-force detection. Temporary lockouts only by default: a permanent lockout lets
      # anyone who knows a username lock that account out (denial of service on public realms).
      brute_force_detection = optional(object({
        permanent_lockout                = optional(bool, false)
        max_login_failures               = optional(number, 30)
        wait_increment_seconds           = optional(number, 60)
        quick_login_check_milli_seconds  = optional(number, 1000)
        minimum_quick_login_wait_seconds = optional(number, 60)
        max_failure_wait_seconds         = optional(number, 900)
        failure_reset_time_seconds       = optional(number, 43200)
        max_temporary_lockouts           = optional(number) # null = Keycloak default
        brute_force_strategy             = optional(string) # MULTIPLE or LINEAR, null = Keycloak default
      }), {})
    }), {})

    # Multi-factor authentication (OTP). null = not managed by this module (Keycloak defaults)
    # required = false: users may enroll OTP, asked at login once configured (built-in browser flow)
    # required = true : every user must enroll and use OTP (dedicated browser flow bound to the realm)
    mfa = optional(object({
      required = optional(bool, false)
      otp_policy = optional(object({
        type              = optional(string, "totp")
        algorithm         = optional(string, "HmacSHA1")
        digits            = optional(number, 6)
        period            = optional(number, 30)
        initial_counter   = optional(number, 0)
        look_ahead_window = optional(number, 1)
      }), {})
    }))

    # Login and admin events. null = not managed by this module (Keycloak defaults: disabled)
    events = optional(object({
      events_enabled               = optional(bool, true)
      events_expiration            = optional(number, 2592000)  # seconds, 30 days
      enabled_event_types          = optional(list(string), []) # empty = all event types
      admin_events_enabled         = optional(bool, true)
      admin_events_details_enabled = optional(bool, false) # stores full representations, may contain personal data
      events_listeners             = optional(list(string), ["jboss-logging"])
    }))

    # Google reCAPTCHA on the registration form (requires registration_allowed = true)
    # Secret key is passed separately through keycloak_realm_recaptcha_secret
    registration_captcha = optional(object({
      site_key             = string
      action               = optional(string, "register")
      invisible            = optional(bool, false) # true = reCAPTCHA v3 (score based, no checkbox)
      use_recaptcha_net    = optional(bool, false) # load from recaptcha.net instead of google.com
      terms_and_conditions = optional(bool, false) # add the terms and conditions step to registration
    }))

    # Declarative user profile. null = not managed by this module (Keycloak defaults)
    # Built-in attributes (username, email, firstName, lastName) are always declared with Keycloak default validators
    user_profile = optional(object({
      unmanaged_attribute_policy = optional(string)                                           # null (disabled), ENABLED, ADMIN_VIEW, ADMIN_EDIT
      user_editable              = optional(list(string), ["email", "firstName", "lastName"]) # built-in attributes users may edit themselves
      required                   = optional(list(string), ["email", "firstName", "lastName"]) # built-in attributes required for users
      groups = optional(list(object({
        name                = string
        display_header      = optional(string)
        display_description = optional(string)
      })), [])
      attributes = optional(list(object({
        name               = string
        display_name       = optional(string)
        group              = optional(string)
        multi_valued       = optional(bool, false)
        required_for_roles = optional(list(string), [])
        view               = optional(list(string), ["admin", "user"])
        edit               = optional(list(string), ["admin"])
        validators         = optional(map(map(string)), {}) # validator name => config
        annotations        = optional(map(string), {})
      })), [])
    }))

    # Fine-grained admin permissions (v2), required for client admin_permissions
    admin_permissions_enabled = optional(bool, false)

    # SMTP password is passed separately through keycloak_realm_smtp_password
    smtp_server = optional(object({
      host                  = string
      port                  = optional(string, "587")
      from                  = string
      from_display_name     = optional(string)
      reply_to              = optional(string)
      reply_to_display_name = optional(string)
      envelope_from         = optional(string)
      ssl                   = optional(bool, false)
      starttls              = optional(bool, true)
      auth_username         = optional(string)
    }))
  })
  description = "Keycloak realm configuration including name, display name, login and self-service options, MFA, SMTP server, default email domain, and default user groups"

  validation {
    condition     = contains(["totp", "hotp"], try(var.keycloak_realm.mfa.otp_policy.type, "totp"))
    error_message = "keycloak_realm.mfa.otp_policy.type must be \"totp\" or \"hotp\"."
  }

  validation {
    condition     = contains(["HmacSHA1", "HmacSHA256", "HmacSHA512"], try(var.keycloak_realm.mfa.otp_policy.algorithm, "HmacSHA1"))
    error_message = "keycloak_realm.mfa.otp_policy.algorithm must be one of HmacSHA1, HmacSHA256, HmacSHA512."
  }

  validation {
    condition     = contains([6, 8], try(var.keycloak_realm.mfa.otp_policy.digits, 6))
    error_message = "keycloak_realm.mfa.otp_policy.digits must be 6 or 8."
  }

  validation {
    condition     = contains(["MULTIPLE", "LINEAR"], coalesce(try(var.keycloak_realm.security_defenses.brute_force_detection.brute_force_strategy, null), "MULTIPLE"))
    error_message = "keycloak_realm.security_defenses.brute_force_detection.brute_force_strategy must be null, MULTIPLE or LINEAR."
  }

  validation {
    condition     = try(var.keycloak_realm.security_defenses.brute_force_detection.max_login_failures, 30) >= 1
    error_message = "keycloak_realm.security_defenses.brute_force_detection.max_login_failures must be at least 1."
  }

  validation {
    condition     = try(var.keycloak_realm.registration_captcha, null) == null || var.keycloak_realm.registration_allowed
    error_message = "keycloak_realm.registration_captcha requires keycloak_realm.registration_allowed = true."
  }

  validation {
    condition     = contains(["DISABLED", "ENABLED", "ADMIN_VIEW", "ADMIN_EDIT"], coalesce(try(var.keycloak_realm.user_profile.unmanaged_attribute_policy, null), "DISABLED"))
    error_message = "keycloak_realm.user_profile.unmanaged_attribute_policy must be null, ENABLED, ADMIN_VIEW or ADMIN_EDIT."
  }
}

variable "keycloak_realm_smtp_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "Password of the realm SMTP server, used when keycloak_realm.smtp_server.auth_username is set"
}

variable "keycloak_realm_recaptcha_secret" {
  type        = string
  default     = null
  sensitive   = true
  description = "Google reCAPTCHA secret key, required when keycloak_realm.registration_captcha is set"
}

variable "keycloak_identity_providers" {
  type = list(object({
    alias        = string
    type         = string # google, github, microsoft or oidc
    display_name = optional(string)
    enabled      = optional(bool, true)
    client_id    = string

    # Only trust emails from providers that verify them (e.g. Google). Unverified emails allow account takeover.
    trust_email                   = optional(bool, false)
    sync_mode                     = optional(string, "IMPORT") # IMPORT, LEGACY or FORCE
    hide_on_login_page            = optional(bool, false)
    gui_order                     = optional(string)
    default_scopes                = optional(string)
    store_token                   = optional(bool, false)
    first_broker_login_flow_alias = optional(string)
    post_broker_login_flow_alias  = optional(string)
    extra_config                  = optional(map(string), {})

    # google only: restrict logins to a Google Workspace domain
    hosted_domain = optional(string)

    # microsoft only: Entra ID tenant ("common" = any Microsoft account, or a tenant ID to restrict)
    tenant_id = optional(string)

    # oidc only
    issuer             = optional(string)
    authorization_url  = optional(string)
    token_url          = optional(string)
    user_info_url      = optional(string)
    jwks_url           = optional(string)
    logout_url         = optional(string)
    validate_signature = optional(bool, true)
  }))
  default     = []
  description = "External identity providers (Google, GitHub, Microsoft, generic OIDC) brokered by the realm. Client secrets are passed through keycloak_identity_provider_secrets"

  validation {
    condition     = alltrue([for idp in var.keycloak_identity_providers : contains(["google", "github", "microsoft", "oidc"], idp.type)])
    error_message = "keycloak_identity_providers[*].type must be one of google, github, microsoft, oidc."
  }

  validation {
    condition = alltrue([
      for idp in var.keycloak_identity_providers :
      idp.type != "oidc" || (idp.authorization_url != null && idp.token_url != null)
    ])
    error_message = "oidc identity providers require authorization_url and token_url."
  }
}

variable "keycloak_identity_provider_secrets" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Client secrets of the identity providers, keyed by identity provider alias"
}

variable "keycloak_groups" {
  type = list(object({
    name        = string
    path        = optional(string, "") # Parent path like "/Organization/Engineering" (empty = root)
    roles       = optional(list(string), [])
    permissions = optional(list(map(string)), [])
    attributes  = optional(map(list(string)), {})
  }))
  default     = []
  description = "List of Keycloak groups with hierarchy and configuration (empty = groups are not managed by this module)"
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
  default     = []
  description = "List of users to create (empty = users are not managed by this module)"
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
    name                      = string
    enabled                   = optional(bool, true)
    description               = optional(string, null)
    always_display_in_console = optional(bool, null)
    # false = tokens only carry roles explicitly scoped to the client (null = Keycloak default: true)
    full_scope_allowed           = optional(bool, null)
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
    pkce_code_challenge_method      = optional(string, null) # "S256" for public clients (SPA, mobile)

    # Roles granted to the client service account (requires service_accounts_enabled = true)
    # Client roles keyed by the client_id owning them, e.g. { "realm-management" = ["manage-users", "view-users"] }
    service_account_roles       = optional(map(list(string)), {})
    service_account_realm_roles = optional(list(string), [])

    # Scoped delegated administration for the service account (requires keycloak_realm.admin_permissions_enabled)
    # all_users_scopes: scopes on every user (view, manage, impersonate, map-roles, manage-group-membership)
    # groups          : group name => scopes (view, manage, view-members, manage-members, manage-membership, impersonate-members)
    admin_permissions = optional(object({
      all_users_scopes = optional(list(string), [])
      groups           = optional(map(list(string)), {})
    }))

    # Add an "identity_provider" claim with the external IdP alias used to log in (absent for local logins)
    identity_provider_claim = optional(bool, false)

    oidc_group_membership_mappers = optional(list(object({
      name       = string
      claim_name = string
      full_path  = optional(bool)
      # Keycloak defaults: groups claim added to every token type
      add_to_id_token            = optional(bool, true)
      add_to_access_token        = optional(bool, true)
      add_to_userinfo            = optional(bool, true)
      add_to_token_introspection = optional(bool, true)
    })))
  }))
  default     = []
  description = "Keycloak OpenID Connect (OIDC) clients and their settings (flows, URLs, secrets, mappers, logout, web origins, etc.)"
}
