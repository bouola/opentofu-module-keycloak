locals {
  oidc_clients_by_name = {
    for openid_client in var.keycloak_oidc_clients :
    openid_client.name => openid_client
  }

  # client_id => name of the OIDC clients managed by this module
  oidc_client_names_by_client_id = {
    for openid_client in var.keycloak_oidc_clients :
    lower(replace(openid_client.name, " ", "-")) => openid_client.name
  }

  oidc_service_account_client_roles = flatten([
    for openid_client in var.keycloak_oidc_clients : [
      for role_client_id, roles in openid_client.service_account_roles : [
        for role in roles : {
          client_name    = openid_client.name
          role_client_id = role_client_id
          role           = role
        }
      ]
    ]
  ])

  oidc_service_account_realm_roles = flatten([
    for openid_client in var.keycloak_oidc_clients : [
      for role in openid_client.service_account_realm_roles : {
        client_name = openid_client.name
        role        = role
      }
    ]
  ])

  # Clients owning roles but not managed by this module (e.g. built-in realm-management)
  oidc_service_account_external_role_clients = toset([
    for role in local.oidc_service_account_client_roles :
    role.role_client_id if !contains(keys(local.oidc_client_names_by_client_id), role.role_client_id)
  ])
}

data "keycloak_openid_client" "service_account_role_clients" {
  for_each  = local.oidc_service_account_external_role_clients
  realm_id  = keycloak_realm.realm.id
  client_id = each.key

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_openid_client_service_account_role" "service_account_roles" {
  for_each = {
    for role in local.oidc_service_account_client_roles :
    "${role.client_name}-${role.role_client_id}-${role.role}" => role
  }
  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.openid_clients[each.value.client_name].service_account_user_id
  client_id = (
    contains(keys(local.oidc_client_names_by_client_id), each.value.role_client_id)
    ? keycloak_openid_client.openid_clients[local.oidc_client_names_by_client_id[each.value.role_client_id]].id
    : data.keycloak_openid_client.service_account_role_clients[each.value.role_client_id].id
  )
  role = each.value.role

  lifecycle {
    precondition {
      condition     = local.oidc_clients_by_name[each.value.client_name].service_accounts_enabled
      error_message = "OIDC client \"${each.value.client_name}\" must set service_accounts_enabled = true to receive service account roles."
    }
  }

  depends_on = [
    time_sleep.after_oidc_clients
  ]
}

resource "keycloak_openid_client_service_account_realm_role" "service_account_realm_roles" {
  for_each = {
    for role in local.oidc_service_account_realm_roles :
    "${role.client_name}-${role.role}" => role
  }
  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.openid_clients[each.value.client_name].service_account_user_id
  role                    = each.value.role

  lifecycle {
    precondition {
      condition     = local.oidc_clients_by_name[each.value.client_name].service_accounts_enabled
      error_message = "OIDC client \"${each.value.client_name}\" must set service_accounts_enabled = true to receive service account realm roles."
    }
  }

  depends_on = [
    time_sleep.after_oidc_clients
  ]
}

# Role scope mappings of the service account roles: with full_scope_allowed = false, an access token only carries the
# roles that are both assigned to the service account and in the client scope. Keycloak deprecates
# full_scope_allowed = true, so each service account role is also scoped to its client.
data "keycloak_role" "service_account_client_roles" {
  for_each = {
    for role in local.oidc_service_account_client_roles :
    "${role.role_client_id}/${role.role}" => role...
  }
  realm_id = keycloak_realm.realm.id
  client_id = (
    contains(keys(local.oidc_client_names_by_client_id), each.value[0].role_client_id)
    ? keycloak_openid_client.openid_clients[local.oidc_client_names_by_client_id[each.value[0].role_client_id]].id
    : data.keycloak_openid_client.service_account_role_clients[each.value[0].role_client_id].id
  )
  name = each.value[0].role

  depends_on = [
    time_sleep.after_oidc_clients
  ]
}

data "keycloak_role" "service_account_realm_roles" {
  for_each = toset([for role in local.oidc_service_account_realm_roles : role.role])
  realm_id = keycloak_realm.realm.id
  name     = each.key

  depends_on = [
    time_sleep.after_realm
  ]
}

resource "keycloak_generic_role_mapper" "service_account_client_role_scopes" {
  for_each = {
    for role in local.oidc_service_account_client_roles :
    "${role.client_name}-${role.role_client_id}-${role.role}" => role
  }
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.openid_clients[each.value.client_name].id
  role_id   = data.keycloak_role.service_account_client_roles["${each.value.role_client_id}/${each.value.role}"].id
}

resource "keycloak_generic_role_mapper" "service_account_realm_role_scopes" {
  for_each = {
    for role in local.oidc_service_account_realm_roles :
    "${role.client_name}-${role.role}" => role
  }
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.openid_clients[each.value.client_name].id
  role_id   = data.keycloak_role.service_account_realm_roles[each.value.role].id
}
