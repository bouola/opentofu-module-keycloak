locals {
  keycloak_realm_display_name = coalesce(var.keycloak_realm.display_name, var.keycloak_realm.name)

  # reCAPTCHA widget is rendered in an iframe served by Google
  keycloak_recaptcha_frame_src = (
    var.keycloak_realm.registration_captcha == null ? "" :
    var.keycloak_realm.registration_captcha.use_recaptcha_net ? " https://www.recaptcha.net" : " https://www.google.com"
  )
}

resource "keycloak_realm" "realm" {
  realm             = var.keycloak_realm.name
  enabled           = true
  display_name      = local.keycloak_realm_display_name
  display_name_html = "<div class=\"kc-logo-text\"><span>${local.keycloak_realm_display_name}</span></div>"
  remember_me       = true

  login_theme              = var.keycloak_realm.login_theme
  email_theme              = var.keycloak_realm.email_theme
  login_with_email_allowed = var.keycloak_realm.login_with_email_allowed

  # User self-service
  registration_allowed           = var.keycloak_realm.registration_allowed
  registration_email_as_username = var.keycloak_realm.registration_email_as_username
  edit_username_allowed          = var.keycloak_realm.edit_username_allowed
  duplicate_emails_allowed       = var.keycloak_realm.duplicate_emails_allowed
  verify_email                   = var.keycloak_realm.verify_email
  reset_password_allowed         = var.keycloak_realm.reset_password_allowed

  admin_permissions_enabled = var.keycloak_realm.admin_permissions_enabled

  access_code_lifespan = var.keycloak_realm.access_code_lifespan

  ssl_required    = var.keycloak_realm.ssl_required
  password_policy = var.keycloak_realm.password_policy

  internationalization {
    supported_locales = var.keycloak_realm.internationalization.supported_locales
    default_locale    = var.keycloak_realm.internationalization.default_locale
  }

  security_defenses {
    headers {
      x_frame_options                     = "DENY"
      content_security_policy             = "frame-src 'self'${local.keycloak_recaptcha_frame_src}; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                = var.keycloak_realm.security_defenses.brute_force_detection.permanent_lockout
      max_login_failures               = var.keycloak_realm.security_defenses.brute_force_detection.max_login_failures
      wait_increment_seconds           = var.keycloak_realm.security_defenses.brute_force_detection.wait_increment_seconds
      quick_login_check_milli_seconds  = var.keycloak_realm.security_defenses.brute_force_detection.quick_login_check_milli_seconds
      minimum_quick_login_wait_seconds = var.keycloak_realm.security_defenses.brute_force_detection.minimum_quick_login_wait_seconds
      max_failure_wait_seconds         = var.keycloak_realm.security_defenses.brute_force_detection.max_failure_wait_seconds
      failure_reset_time_seconds       = var.keycloak_realm.security_defenses.brute_force_detection.failure_reset_time_seconds
      max_temporary_lockouts           = var.keycloak_realm.security_defenses.brute_force_detection.max_temporary_lockouts
      brute_force_strategy             = var.keycloak_realm.security_defenses.brute_force_detection.brute_force_strategy
    }
  }

  dynamic "otp_policy" {
    for_each = var.keycloak_realm.mfa != null ? [var.keycloak_realm.mfa.otp_policy] : []
    content {
      type              = otp_policy.value.type
      algorithm         = otp_policy.value.algorithm
      digits            = otp_policy.value.digits
      period            = otp_policy.value.period
      initial_counter   = otp_policy.value.initial_counter
      look_ahead_window = otp_policy.value.look_ahead_window
    }
  }

  dynamic "smtp_server" {
    for_each = var.keycloak_realm.smtp_server != null ? [var.keycloak_realm.smtp_server] : []
    content {
      host                  = smtp_server.value.host
      port                  = smtp_server.value.port
      from                  = smtp_server.value.from
      from_display_name     = smtp_server.value.from_display_name
      reply_to              = smtp_server.value.reply_to
      reply_to_display_name = smtp_server.value.reply_to_display_name
      envelope_from         = smtp_server.value.envelope_from
      ssl                   = smtp_server.value.ssl
      starttls              = smtp_server.value.starttls

      dynamic "auth" {
        for_each = smtp_server.value.auth_username != null ? [smtp_server.value.auth_username] : []
        content {
          username = auth.value
          password = var.keycloak_realm_smtp_password
        }
      }
    }
  }

  # Manual edit user attributes for disallow user to update some fields
}

resource "time_sleep" "after_realm" {
  depends_on      = [keycloak_realm.realm]
  create_duration = "30s"
}
