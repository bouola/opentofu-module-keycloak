# opentofu-module-keycloak
Keycloak management with OpenTofu

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 5.7.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_keycloak"></a> [keycloak](#provider\_keycloak) | >= 5.7.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [keycloak_authentication_bindings.bindings](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_bindings) | resource |
| [keycloak_authentication_execution.browser_mfa_cookie](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.browser_mfa_idp_redirector](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.browser_mfa_otp](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.browser_mfa_username_password](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.registration_captcha_password](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.registration_captcha_recaptcha](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.registration_captcha_terms](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.registration_captcha_user_creation](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution_config.registration_captcha_recaptcha](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution_config) | resource |
| [keycloak_authentication_flow.browser_mfa](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_flow) | resource |
| [keycloak_authentication_flow.registration_captcha](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_flow) | resource |
| [keycloak_authentication_subflow.browser_mfa_forms](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_subflow) | resource |
| [keycloak_authentication_subflow.registration_captcha_form](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_subflow) | resource |
| [keycloak_group.level_0](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level_1](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level_2](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level_3](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_admin_permissions.admin_permissions_groups](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_admin_permissions) | resource |
| [keycloak_oidc_github_identity_provider.github](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_github_identity_provider) | resource |
| [keycloak_oidc_google_identity_provider.google](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_google_identity_provider) | resource |
| [keycloak_oidc_identity_provider.oidc](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_identity_provider) | resource |
| [keycloak_oidc_microsoft_identity_provider.microsoft](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_microsoft_identity_provider) | resource |
| [keycloak_openid_client.openid_clients](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client_service_account_realm_role.service_account_realm_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_service_account_realm_role) | resource |
| [keycloak_openid_client_service_account_role.service_account_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_service_account_role) | resource |
| [keycloak_openid_client_user_policy.admin_permissions_service_accounts](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_user_policy) | resource |
| [keycloak_openid_group_membership_protocol_mapper.group_membership_mappers](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_group_membership_protocol_mapper) | resource |
| [keycloak_realm.realm](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_realm_events.realm_events](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_events) | resource |
| [keycloak_realm_user_profile.user_profile](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_user_profile) | resource |
| [keycloak_required_action.configure_totp](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/required_action) | resource |
| [keycloak_saml_client.saml_clients](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_client) | resource |
| [keycloak_saml_user_attribute_protocol_mapper.saml_user_attribute_mappers](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_user_attribute_protocol_mapper) | resource |
| [keycloak_user.users](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user) | resource |
| [keycloak_user_groups.user_groups](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user_groups) | resource |
| [keycloak_users_admin_permissions.admin_permissions_all_users](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/users_admin_permissions) | resource |
| [time_sleep.after_groups](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.after_oidc_clients](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.after_realm](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.after_saml_clients](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.after_users](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [keycloak_openid_client.admin_permissions](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/data-sources/openid_client) | data source |
| [keycloak_openid_client.service_account_role_clients](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/data-sources/openid_client) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_keycloak_client_id"></a> [keycloak\_client\_id](#input\_keycloak\_client\_id) | Keycloak client ID for authentication | `string` | n/a | yes |
| <a name="input_keycloak_groups"></a> [keycloak\_groups](#input\_keycloak\_groups) | List of Keycloak groups with hierarchy and configuration | <pre>list(object({<br/>    name        = string<br/>    path        = optional(string, "") # Parent path like "/Organization/Engineering" (empty = root)<br/>    roles       = optional(list(string), [])<br/>    permissions = optional(list(map(string)), [])<br/>    attributes  = optional(map(list(string)), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_keycloak_oidc_clients"></a> [keycloak\_oidc\_clients](#input\_keycloak\_oidc\_clients) | Keycloak OpenID Connect (OIDC) clients and their settings (flows, URLs, secrets, mappers, logout, web origins, etc.) | <pre>list(object({<br/>    name                         = string<br/>    enabled                      = optional(bool, true)<br/>    description                  = optional(string, null)<br/>    always_display_in_console    = optional(bool, null)<br/>    access_type                  = optional(string, "CONFIDENTIAL")<br/>    client_secret                = optional(string, null)<br/>    standard_flow_enabled        = optional(bool, true)<br/>    implicit_flow_enabled        = optional(bool, false)<br/>    direct_access_grants_enabled = optional(bool, false)<br/>    service_accounts_enabled     = optional(bool, false)<br/>    authorization = optional(object({<br/>      allow_remote_resource_management = optional(bool, true)<br/>      decision_strategy                = optional(string, "UNANIMOUS")<br/>      policy_enforcement_mode          = optional(string, "ENFORCING")<br/>      keep_defaults                    = optional(bool, false)<br/>    }), null)<br/>    root_url                        = optional(string, null)<br/>    admin_url                       = optional(string, null)<br/>    base_url                        = optional(string, null)<br/>    valid_redirect_uris             = optional(list(string), null)<br/>    valid_post_logout_redirect_uris = optional(list(string), null)<br/>    web_origins                     = optional(list(string), null)<br/>    frontchannel_logout_enabled     = optional(bool, false)<br/>    frontchannel_logout_url         = optional(string, null)<br/><br/>    oidc_group_membership_mappers = optional(list(object({<br/>      name       = string<br/>      claim_name = string<br/>      full_path  = optional(bool)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_keycloak_password"></a> [keycloak\_password](#input\_keycloak\_password) | Keycloak admin password for authentication | `string` | n/a | yes |
| <a name="input_keycloak_realm"></a> [keycloak\_realm](#input\_keycloak\_realm) | Keycloak realm configuration including name, display name, default email domain, and default user groups | <pre>object({<br/>    name                     = string<br/>    display_name             = optional(string)<br/>    default_email_domain     = string<br/>    default_usergroups       = optional(list(string), [])<br/>    login_theme              = optional(string, "keycloak.v2")<br/>    login_with_email_allowed = optional(bool, true)<br/>    access_code_lifespan     = optional(string, "1h")<br/>    ssl_required             = optional(string, "external")<br/>    password_policy          = optional(string, "upperCase(1) and length(10) and forceExpiredPasswordChange(365) and notUsername")<br/>    internationalization = optional(object({<br/>      supported_locales = optional(list(string), ["en", "fr"])<br/>      default_locale    = optional(string, "en")<br/>    }), {})<br/>    security_defenses = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_keycloak_saml_clients"></a> [keycloak\_saml\_clients](#input\_keycloak\_saml\_clients) | Keycloak SAML clients | <pre>list(object({<br/>    name                       = string<br/>    description                = optional(string)<br/>    root_url                   = string<br/>    base_url                   = string<br/>    valid_redirect_uris        = optional(set(string))<br/>    master_saml_processing_url = string<br/>    name_id_format             = string<br/>    include_authn_statement    = optional(bool, false)<br/>    force_post_binding         = optional(bool, true)<br/>    sign_documents             = optional(bool, false)<br/>    sign_assertions            = optional(bool, false)<br/>    signature_algorithm        = optional(string)<br/>    front_channel_logout       = optional(bool, true)<br/>    saml_attribute_mappers = optional(list(object({<br/>      name                       = string<br/>      user_attribute             = string<br/>      saml_attribute_name        = string<br/>      saml_attribute_name_format = optional(string, "Basic")<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | Base URL of the Keycloak server | `string` | n/a | yes |
| <a name="input_keycloak_username"></a> [keycloak\_username](#input\_keycloak\_username) | Keycloak admin username for authentication | `string` | n/a | yes |
| <a name="input_keycloak_users"></a> [keycloak\_users](#input\_keycloak\_users) | List of users to create | <pre>list(object({<br/>    firstname      = string<br/>    lastname       = string<br/>    username       = optional(string, null)<br/>    force_username = optional(bool, false)<br/>    groups         = optional(list(string), [])<br/>    roles          = optional(list(string), [])<br/>    attributes     = optional(map(string), {})<br/>    is_external    = optional(bool, false)<br/>    enabled        = optional(bool, true)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
