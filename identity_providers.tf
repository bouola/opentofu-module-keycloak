locals {
  keycloak_identity_providers = {
    for idp in var.keycloak_identity_providers :
    idp.alias => idp
  }
}

resource "keycloak_oidc_google_identity_provider" "google" {
  for_each = { for alias, idp in local.keycloak_identity_providers : alias => idp if idp.type == "google" }
  realm    = keycloak_realm.realm.id
  alias    = each.key

  display_name  = each.value.display_name
  enabled       = each.value.enabled
  client_id     = each.value.client_id
  client_secret = lookup(var.keycloak_identity_provider_secrets, each.key, null)
  hosted_domain = each.value.hosted_domain

  trust_email                   = each.value.trust_email
  sync_mode                     = each.value.sync_mode
  hide_on_login_page            = each.value.hide_on_login_page
  gui_order                     = each.value.gui_order
  default_scopes                = each.value.default_scopes
  store_token                   = each.value.store_token
  first_broker_login_flow_alias = each.value.first_broker_login_flow_alias
  post_broker_login_flow_alias  = each.value.post_broker_login_flow_alias
  extra_config                  = each.value.extra_config

  lifecycle {
    precondition {
      condition     = contains(keys(var.keycloak_identity_provider_secrets), each.key)
      error_message = "Missing client secret for identity provider \"${each.key}\" in keycloak_identity_provider_secrets."
    }
  }

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_oidc_github_identity_provider" "github" {
  for_each = { for alias, idp in local.keycloak_identity_providers : alias => idp if idp.type == "github" }
  realm    = keycloak_realm.realm.id
  alias    = each.key

  display_name  = each.value.display_name
  enabled       = each.value.enabled
  client_id     = each.value.client_id
  client_secret = lookup(var.keycloak_identity_provider_secrets, each.key, null)

  trust_email                   = each.value.trust_email
  sync_mode                     = each.value.sync_mode
  hide_on_login_page            = each.value.hide_on_login_page
  gui_order                     = each.value.gui_order
  default_scopes                = each.value.default_scopes
  store_token                   = each.value.store_token
  first_broker_login_flow_alias = each.value.first_broker_login_flow_alias
  post_broker_login_flow_alias  = each.value.post_broker_login_flow_alias
  extra_config                  = each.value.extra_config

  lifecycle {
    precondition {
      condition     = contains(keys(var.keycloak_identity_provider_secrets), each.key)
      error_message = "Missing client secret for identity provider \"${each.key}\" in keycloak_identity_provider_secrets."
    }
  }

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_oidc_identity_provider" "oidc" {
  for_each = { for alias, idp in local.keycloak_identity_providers : alias => idp if idp.type == "oidc" }
  realm    = keycloak_realm.realm.id
  alias    = each.key

  display_name  = each.value.display_name
  enabled       = each.value.enabled
  client_id     = each.value.client_id
  client_secret = lookup(var.keycloak_identity_provider_secrets, each.key, null)

  issuer             = each.value.issuer
  authorization_url  = each.value.authorization_url
  token_url          = each.value.token_url
  user_info_url      = each.value.user_info_url
  jwks_url           = each.value.jwks_url
  logout_url         = each.value.logout_url
  validate_signature = each.value.validate_signature

  trust_email                   = each.value.trust_email
  sync_mode                     = each.value.sync_mode
  hide_on_login_page            = each.value.hide_on_login_page
  gui_order                     = each.value.gui_order
  default_scopes                = each.value.default_scopes
  store_token                   = each.value.store_token
  first_broker_login_flow_alias = each.value.first_broker_login_flow_alias
  post_broker_login_flow_alias  = each.value.post_broker_login_flow_alias
  extra_config                  = each.value.extra_config

  lifecycle {
    precondition {
      condition     = contains(keys(var.keycloak_identity_provider_secrets), each.key)
      error_message = "Missing client secret for identity provider \"${each.key}\" in keycloak_identity_provider_secrets."
    }
  }

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_oidc_microsoft_identity_provider" "microsoft" {
  for_each = { for alias, idp in local.keycloak_identity_providers : alias => idp if idp.type == "microsoft" }
  realm    = keycloak_realm.realm.id
  alias    = each.key

  display_name  = each.value.display_name
  enabled       = each.value.enabled
  client_id     = each.value.client_id
  client_secret = lookup(var.keycloak_identity_provider_secrets, each.key, null)
  tenant_id     = each.value.tenant_id

  trust_email                   = each.value.trust_email
  sync_mode                     = each.value.sync_mode
  hide_on_login_page            = each.value.hide_on_login_page
  gui_order                     = each.value.gui_order
  default_scopes                = each.value.default_scopes
  store_token                   = each.value.store_token
  first_broker_login_flow_alias = each.value.first_broker_login_flow_alias
  post_broker_login_flow_alias  = each.value.post_broker_login_flow_alias
  extra_config                  = each.value.extra_config

  lifecycle {
    precondition {
      condition     = contains(keys(var.keycloak_identity_provider_secrets), each.key)
      error_message = "Missing client secret for identity provider \"${each.key}\" in keycloak_identity_provider_secrets."
    }
  }

  depends_on = [
    time_sleep.after_realm
  ]
}
