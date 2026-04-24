resource "keycloak_realm" "realm" {
  realm             = var.keycloak_realm.name
  enabled           = true
  display_name      = lookup(var.keycloak_realm, "display_name", var.keycloak_realm.name)
  display_name_html = "<div class=\"kc-logo-text\"><span>${lookup(var.keycloak_realm, "display_name", var.keycloak_realm.name)}</span></div>"
  remember_me       = true

  login_theme              = var.keycloak_realm.login_theme
  login_with_email_allowed = var.keycloak_realm.login_with_email_allowed

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
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                = false
      max_login_failures               = 30
      wait_increment_seconds           = 60
      quick_login_check_milli_seconds  = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds         = 900
      failure_reset_time_seconds       = 43200
    }
  }

  # Manual edit user attributes for disallow user to update some fields
}
