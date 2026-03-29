
locals {
  keycloak_users = [
    for user in var.keycloak_users :
    merge(user, {
      username = user.force_username ? lookup(user, "username", "${replace(lower(user.firstname), " ", "-")}.${replace(lower(user.lastname), " ", "-")}") : "${replace(lower(user.firstname), " ", "-")}.${replace(lower(user.lastname), " ", "-")}"
      groups   = concat(var.keycloak_realm.default_usergroups, user.groups)
    })
  ]
}

resource "keycloak_user" "users" {
  for_each   = { for user in local.keycloak_users : user.username => user }
  realm_id   = keycloak_realm.realm.id
  username   = each.key
  email      = each.value.is_external ? "${each.key}-extern@${var.keycloak_realm.default_email_domain}" : "${each.key}@${lower(var.keycloak_realm.default_email_domain)}"
  first_name = each.value.firstname
  last_name  = each.value.lastname
  enabled    = each.value.enabled

  required_actions = [
    "UPDATE_PASSWORD"
  ]

  attributes = merge(
    {
      is_external = tostring(each.value.is_external)
    },
    each.value.attributes
  )

  email_verified = true

  initial_password {
    value     = "${title(each.key)}&!"
    temporary = true
  }

  lifecycle {
    ignore_changes = [
      attributes,
      required_actions
    ]
  }
}

resource "keycloak_user_groups" "user_groups" {
  for_each = {
    for user in local.keycloak_users :
    user.username => user if user.enabled
  }
  group_ids = [
    for group in each.value.groups :
    local.keycloak_all_groups[group].id
  ]
  realm_id = keycloak_realm.realm.id
  user_id  = keycloak_user.users[each.key].id
}
