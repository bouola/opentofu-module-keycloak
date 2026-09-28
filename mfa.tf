locals {
  keycloak_mfa_managed  = var.keycloak_realm.mfa != null
  keycloak_mfa_required = try(var.keycloak_realm.mfa.required, false)
  keycloak_mfa_flow     = "browser-mfa"
}

# Allow users to enroll OTP; as default action, newly created users must enroll it
resource "keycloak_required_action" "configure_totp" {
  count          = local.keycloak_mfa_managed ? 1 : 0
  realm_id       = keycloak_realm.realm.id
  alias          = "CONFIGURE_TOTP"
  name           = "Configure OTP"
  enabled        = true
  default_action = local.keycloak_mfa_required

  depends_on = [
    time_sleep.after_realm
  ]
}

# Browser flow with mandatory OTP: users without OTP configured must enroll at next login
resource "keycloak_authentication_flow" "browser_mfa" {
  count       = local.keycloak_mfa_required ? 1 : 0
  realm_id    = keycloak_realm.realm.id
  alias       = local.keycloak_mfa_flow
  description = "Browser based authentication with mandatory OTP (managed by OpenTofu)"

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_authentication_execution" "browser_mfa_cookie" {
  count             = local.keycloak_mfa_required ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.browser_mfa[0].alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
  priority          = 10
}

resource "keycloak_authentication_execution" "browser_mfa_idp_redirector" {
  count             = local.keycloak_mfa_required ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.browser_mfa[0].alias
  authenticator     = "identity-provider-redirector"
  requirement       = "ALTERNATIVE"
  priority          = 20
}

resource "keycloak_authentication_subflow" "browser_mfa_forms" {
  count             = local.keycloak_mfa_required ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.browser_mfa[0].alias
  alias             = "${local.keycloak_mfa_flow}-forms"
  description       = "Username, password and OTP"
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 30
}

resource "keycloak_authentication_execution" "browser_mfa_username_password" {
  count             = local.keycloak_mfa_required ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.browser_mfa_forms[0].alias
  authenticator     = "auth-username-password-form"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "browser_mfa_otp" {
  count             = local.keycloak_mfa_required ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.browser_mfa_forms[0].alias
  authenticator     = "auth-otp-form"
  requirement       = "REQUIRED"
  priority          = 20

  depends_on = [
    keycloak_authentication_execution.browser_mfa_username_password
  ]
}
