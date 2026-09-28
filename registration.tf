locals {
  keycloak_registration_captcha = var.keycloak_realm.registration_captcha != null
  keycloak_registration_flow    = "registration-captcha"
}

# Copy of the built-in registration flow with Google reCAPTCHA enabled
resource "keycloak_authentication_flow" "registration_captcha" {
  count       = local.keycloak_registration_captcha ? 1 : 0
  realm_id    = keycloak_realm.realm.id
  alias       = local.keycloak_registration_flow
  description = "Registration with reCAPTCHA (managed by OpenTofu)"

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_authentication_subflow" "registration_captcha_form" {
  count             = local.keycloak_registration_captcha ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.registration_captcha[0].alias
  alias             = "${local.keycloak_registration_flow}-form"
  description       = "Registration form"
  provider_id       = "form-flow"
  authenticator     = "registration-page-form"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "registration_captcha_user_creation" {
  count             = local.keycloak_registration_captcha ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.registration_captcha_form[0].alias
  authenticator     = "registration-user-creation"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "registration_captcha_password" {
  count             = local.keycloak_registration_captcha ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.registration_captcha_form[0].alias
  authenticator     = "registration-password-action"
  requirement       = "REQUIRED"
  priority          = 20

  depends_on = [
    keycloak_authentication_execution.registration_captcha_user_creation
  ]
}

resource "keycloak_authentication_execution" "registration_captcha_recaptcha" {
  count             = local.keycloak_registration_captcha ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.registration_captcha_form[0].alias
  authenticator     = "registration-recaptcha-action"
  requirement       = "REQUIRED"
  priority          = 30

  depends_on = [
    keycloak_authentication_execution.registration_captcha_password
  ]
}

resource "keycloak_authentication_execution_config" "registration_captcha_recaptcha" {
  count        = local.keycloak_registration_captcha ? 1 : 0
  realm_id     = keycloak_realm.realm.id
  execution_id = keycloak_authentication_execution.registration_captcha_recaptcha[0].id
  alias        = "${var.keycloak_realm.name}-recaptcha"
  config = {
    "site.key"        = var.keycloak_realm.registration_captcha.site_key
    "secret.key"      = var.keycloak_realm_recaptcha_secret
    "action"          = var.keycloak_realm.registration_captcha.action
    "recaptcha.v3"    = tostring(var.keycloak_realm.registration_captcha.invisible)
    "useRecaptchaNet" = tostring(var.keycloak_realm.registration_captcha.use_recaptcha_net)
  }

  lifecycle {
    precondition {
      condition     = var.keycloak_realm_recaptcha_secret != null
      error_message = "keycloak_realm_recaptcha_secret is required when keycloak_realm.registration_captcha is set."
    }
  }
}

resource "keycloak_authentication_execution" "registration_captcha_terms" {
  count             = local.keycloak_registration_captcha && try(var.keycloak_realm.registration_captcha.terms_and_conditions, false) ? 1 : 0
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.registration_captcha_form[0].alias
  authenticator     = "registration-terms-and-conditions"
  requirement       = "REQUIRED"
  priority          = 40

  depends_on = [
    keycloak_authentication_execution.registration_captcha_recaptcha
  ]
}
