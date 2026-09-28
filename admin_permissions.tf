locals {
  # OIDC clients whose service account gets scoped admin permissions
  oidc_admin_permission_clients = {
    for openid_client in var.keycloak_oidc_clients :
    openid_client.name => openid_client.admin_permissions if openid_client.admin_permissions != null
  }

  oidc_admin_permission_group_scopes = flatten([
    for client_name, permissions in local.oidc_admin_permission_clients : [
      for group, scopes in permissions.groups : {
        client_name = client_name
        group       = group
        scopes      = scopes
      }
    ]
  ])
}

# Resource server holding the realm fine-grained admin permissions (created by Keycloak when enabled)
data "keycloak_openid_client" "admin_permissions" {
  count     = length(local.oidc_admin_permission_clients) > 0 ? 1 : 0
  realm_id  = keycloak_realm.realm.id
  client_id = "admin-permissions"

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_openid_client_user_policy" "admin_permissions_service_accounts" {
  for_each           = local.oidc_admin_permission_clients
  realm_id           = keycloak_realm.realm.id
  resource_server_id = data.keycloak_openid_client.admin_permissions[0].id
  name               = "${each.key}-service-account"
  description        = "Service account of client ${each.key} (managed by OpenTofu)"
  users              = [keycloak_openid_client.openid_clients[each.key].service_account_user_id]
  logic              = "POSITIVE"
  decision_strategy  = "UNANIMOUS"

  lifecycle {
    precondition {
      condition     = var.keycloak_realm.admin_permissions_enabled
      error_message = "OIDC client \"${each.key}\" admin_permissions requires keycloak_realm.admin_permissions_enabled = true."
    }
    precondition {
      condition     = local.oidc_clients_by_name[each.key].service_accounts_enabled
      error_message = "OIDC client \"${each.key}\" must set service_accounts_enabled = true to receive admin_permissions."
    }
  }

  depends_on = [
    time_sleep.after_oidc_clients
  ]
}

resource "keycloak_users_admin_permissions" "admin_permissions_all_users" {
  for_each = {
    for client_name, permissions in local.oidc_admin_permission_clients :
    client_name => permissions if length(permissions.all_users_scopes) > 0
  }
  realm_id          = keycloak_realm.realm.id
  name              = "${each.key}-all-users"
  description       = "Scopes of client ${each.key} service account on all users (managed by OpenTofu)"
  scopes            = each.value.all_users_scopes
  policies          = [keycloak_openid_client_user_policy.admin_permissions_service_accounts[each.key].id]
  decision_strategy = "UNANIMOUS"
}

resource "keycloak_group_admin_permissions" "admin_permissions_groups" {
  for_each = {
    for permission in local.oidc_admin_permission_group_scopes :
    "${permission.client_name}-${permission.group}" => permission
  }
  realm_id          = keycloak_realm.realm.id
  name              = "${each.value.client_name}-group-${each.value.group}"
  description       = "Scopes of client ${each.value.client_name} service account on group ${each.value.group} (managed by OpenTofu)"
  group_ids         = try([local.keycloak_all_groups[each.value.group].id], [])
  scopes            = each.value.scopes
  policies          = [keycloak_openid_client_user_policy.admin_permissions_service_accounts[each.value.client_name].id]
  decision_strategy = "UNANIMOUS"

  lifecycle {
    precondition {
      condition     = contains(keys(local.keycloak_all_groups), each.value.group)
      error_message = "Group \"${each.value.group}\" used in admin_permissions of client \"${each.value.client_name}\" must be managed in keycloak_groups."
    }
  }
}
