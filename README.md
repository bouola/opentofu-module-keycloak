# opentofu-module-keycloak
Keycloak management with OpenTofu

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 5.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_keycloak"></a> [keycloak](#provider\_keycloak) | >= 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [keycloak_group.level_0](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level_1](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level_2](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level_3](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_openid_client.openid_clients](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_group_membership_protocol_mapper.group_membership_mappers](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_group_membership_protocol_mapper) | resource |
| [keycloak_realm.realm](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_saml_client.saml_clients](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_client) | resource |
| [keycloak_saml_user_attribute_protocol_mapper.saml_user_attribute_mappers](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_user_attribute_protocol_mapper) | resource |
| [keycloak_user.users](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user) | resource |
| [keycloak_user_groups.user_groups](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user_groups) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_keycloak_client_id"></a> [keycloak\_client\_id](#input\_keycloak\_client\_id) | Keycloak client ID for authentication | `string` | n/a | yes |
| <a name="input_keycloak_groups"></a> [keycloak\_groups](#input\_keycloak\_groups) | List of Keycloak groups with hierarchy and configuration | <pre>list(object({<br/>    name        = string<br/>    path        = optional(string, "") # Parent path like "/Organization/Engineering" (empty = root)<br/>    roles       = optional(list(string), [])<br/>    permissions = optional(list(map(string)), [])<br/>    attributes  = optional(map(list(string)), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_keycloak_oidc_clients"></a> [keycloak\_oidc\_clients](#input\_keycloak\_oidc\_clients) | Keycloak OpenID Connect (OIDC) clients and their settings (flows, URLs, secrets, mappers, logout, web origins, etc.) | <pre>list(object({<br/>    name                         = string<br/>    enabled                      = optional(bool, true)<br/>    description                  = optional(string, null)<br/>    always_display_in_console    = optional(bool, null)<br/>    access_type                  = optional(string, "CONFIDENTIAL")<br/>    client_secret                = optional(string, null)<br/>    standard_flow_enabled        = optional(bool, true)<br/>    implicit_flow_enabled        = optional(bool, false)<br/>    direct_access_grants_enabled = optional(bool, false)<br/>    service_accounts_enabled     = optional(bool, false)<br/>    authorization = optional(object({<br/>      allow_remote_resource_management = optional(bool, true)<br/>      decision_strategy                = optional(string, "UNANIMOUS")<br/>      policy_enforcement_mode          = optional(string, "ENFORCING")<br/>      keep_defaults                    = optional(bool, false)<br/>    }), null)<br/>    root_url                        = optional(string, null)<br/>    admin_url                       = optional(string, null)<br/>    base_url                        = optional(string, null)<br/>    valid_redirect_uris             = optional(list(string), null)<br/>    valid_post_logout_redirect_uris = optional(list(string), null)<br/>    web_origins                     = optional(list(string), null)<br/>    frontchannel_logout_enabled     = optional(bool, false)<br/>    frontchannel_logout_url         = optional(string, null)<br/><br/>    oidc_group_membership_mappers = optional(list(object({<br/>      name       = string<br/>      claim_name = string<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_keycloak_password"></a> [keycloak\_password](#input\_keycloak\_password) | Keycloak admin password for authentication | `string` | n/a | yes |
| <a name="input_keycloak_realm"></a> [keycloak\_realm](#input\_keycloak\_realm) | Keycloak realm configuration including name, display name, default email domain, and default user groups | <pre>object({<br/>    name                     = string<br/>    display_name             = optional(string)<br/>    default_email_domain     = string<br/>    default_usergroups       = optional(list(string), [])<br/>    login_theme              = optional(string, "keycloak.v2")<br/>    login_with_email_allowed = optional(bool, true)<br/>    access_code_lifespan     = optional(string, "1h")<br/>    ssl_required             = optional(string, "external")<br/>    password_policy          = optional(string, "upperCase(1) and length(10) and forceExpiredPasswordChange(365) and notUsername")<br/>    internationalization     = optional(map(string), {})<br/>    security_defenses        = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_keycloak_saml_clients"></a> [keycloak\_saml\_clients](#input\_keycloak\_saml\_clients) | Keycloak SAML clients | <pre>list(object({<br/>    name                       = string<br/>    description                = optional(string)<br/>    root_url                   = string<br/>    base_url                   = string<br/>    valid_redirect_uris        = optional(set(string))<br/>    master_saml_processing_url = string<br/>    name_id_format             = string<br/>    include_authn_statement    = optional(bool, false)<br/>    force_post_binding         = optional(bool, true)<br/>    sign_documents             = optional(bool, false)<br/>    sign_assertions            = optional(bool, false)<br/>    signature_algorithm        = optional(string)<br/>    front_channel_logout       = optional(bool, true)<br/>    saml_attribute_mappers = optional(list(object({<br/>      name                       = string<br/>      user_attribute             = string<br/>      saml_attribute_name        = string<br/>      saml_attribute_name_format = optional(string, "Basic")<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | Base URL of the Keycloak server | `string` | n/a | yes |
| <a name="input_keycloak_username"></a> [keycloak\_username](#input\_keycloak\_username) | Keycloak admin username for authentication | `string` | n/a | yes |
| <a name="input_keycloak_users"></a> [keycloak\_users](#input\_keycloak\_users) | List of users to create | <pre>list(object({<br/>    firstname      = string<br/>    lastname       = string<br/>    username       = optional(string, null)<br/>    force_username = optional(bool, false)<br/>    groups         = optional(list(string), [])<br/>    roles          = optional(list(string), [])<br/>    attributes     = optional(map(string), {})<br/>    is_external    = optional(bool, false)<br/>    enabled        = optional(bool, true)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
