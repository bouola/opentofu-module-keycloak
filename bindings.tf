# Binds the flows managed by this module to the realm; unmanaged flows stay on Keycloak built-ins
resource "keycloak_authentication_bindings" "bindings" {
  count             = local.keycloak_mfa_required || local.keycloak_registration_captcha ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  browser_flow      = local.keycloak_mfa_required ? keycloak_authentication_flow.browser_mfa[0].alias : "browser"
  registration_flow = local.keycloak_registration_captcha ? keycloak_authentication_flow.registration_captcha[0].alias : "registration"

  depends_on = [
    keycloak_authentication_execution.browser_mfa_cookie,
    keycloak_authentication_execution.browser_mfa_idp_redirector,
    keycloak_authentication_execution.browser_mfa_otp,
    keycloak_required_action.configure_totp,
    keycloak_authentication_execution_config.registration_captcha_recaptcha,
    keycloak_authentication_execution.registration_captcha_terms
  ]
}
