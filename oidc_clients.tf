resource "keycloak_openid_client" "openid_clients" {
  for_each = {
    for openid_client in var.keycloak_oidc_clients :
    openid_client.name => openid_client
  }
  realm_id = keycloak_realm.realm.id

  # General Settings
  client_id                 = lower(replace(each.value.name, " ", "-"))
  name                      = each.value.name
  description               = each.value.description
  always_display_in_console = each.value.always_display_in_console

  # Capability config
  access_type                  = each.value.access_type
  client_secret                = each.value.client_secret
  standard_flow_enabled        = each.value.standard_flow_enabled
  implicit_flow_enabled        = each.value.implicit_flow_enabled
  direct_access_grants_enabled = each.value.direct_access_grants_enabled
  service_accounts_enabled     = each.value.service_accounts_enabled

  dynamic "authorization" {
    for_each = each.value.authorization != null ? [each.value.authorization] : []
    content {
      policy_enforcement_mode          = authorization.value.policy_enforcement_mode
      allow_remote_resource_management = authorization.value.allow_remote_resource_management
      decision_strategy                = authorization.value.decision_strategy
      keep_defaults                    = authorization.value.keep_defaults
    }
  }

  # Login Settings
  root_url                        = each.value.root_url
  base_url                        = each.value.base_url
  admin_url                       = each.value.admin_url
  valid_redirect_uris             = each.value.valid_redirect_uris
  valid_post_logout_redirect_uris = each.value.valid_post_logout_redirect_uris
  web_origins                     = each.value.web_origins

  # Logout Settings
  frontchannel_logout_enabled = each.value.frontchannel_logout_enabled
  frontchannel_logout_url     = each.value.frontchannel_logout_url

  depends_on = [
    keycloak_user.users
  ]
}

resource "time_sleep" "after_oidc_clients" {
  depends_on = [
    keycloak_openid_client.openid_clients
  ]

  create_duration = "30s"
}

locals {
  oidc_group_membership_mappers = flatten([
    for client in var.keycloak_oidc_clients : [
      for mapper in coalesce(client.oidc_group_membership_mappers, []) : {
        client_name = client.name
        name        = mapper.name
        claim_name  = mapper.claim_name
        full_path   = mapper.full_path
      }
    ]
  ])
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mappers" {
  for_each = {
    for mapper in local.oidc_group_membership_mappers :
    "${mapper.client_name}-${mapper.name}" => mapper
  }
  realm_id   = keycloak_realm.realm.id
  client_id  = keycloak_openid_client.openid_clients[each.value.client_name].id
  claim_name = each.value.claim_name
  name       = each.value.name
  full_path  = each.value.full_path

  depends_on = [
    time_sleep.after_oidc_clients
  ]
}
