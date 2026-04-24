locals {
  # Parse path string into list and compute level/parent
  keycloak_groups_enriched = {
    for group in var.keycloak_groups : group.name => {
      name        = group.name
      path        = group.path
      path_parts  = group.path != "" ? split("/", group.path) : []
      level       = group.path != "" ? length(split("/", group.path)) : 0
      parent      = group.path != "" ? split("/", group.path)[length(split("/", group.path)) - 1] : null
      roles       = group.roles
      permissions = group.permissions
      attributes  = group.attributes
    }
  }

  # Filter by level
  keycloak_level_0_groups = { for k, v in local.keycloak_groups_enriched : k => v if v.level == 0 }
  keycloak_level_1_groups = { for k, v in local.keycloak_groups_enriched : k => v if v.level == 1 }
  keycloak_level_2_groups = { for k, v in local.keycloak_groups_enriched : k => v if v.level == 2 }
  keycloak_level_3_groups = { for k, v in local.keycloak_groups_enriched : k => v if v.level == 3 }
}


resource "keycloak_group" "level_0" {
  for_each = local.keycloak_level_0_groups
  realm_id = keycloak_realm.realm.id
  name     = each.value.name
  # attributes = lookup(each.value, "attributes", null)
}

resource "keycloak_group" "level_1" {
  for_each  = local.keycloak_level_1_groups
  realm_id  = keycloak_realm.realm.id
  name      = each.value.name
  parent_id = keycloak_group.level_0[each.value.parent].id
  # attributes = lookup(each.value, "attributes", null)
}

resource "keycloak_group" "level_2" {
  for_each  = local.keycloak_level_2_groups
  realm_id  = keycloak_realm.realm.id
  name      = each.value.name
  parent_id = keycloak_group.level_1[each.value.parent].id
  # attributes = lookup(each.value, "attributes", null)
}

resource "keycloak_group" "level_3" {
  for_each  = local.keycloak_level_3_groups
  realm_id  = keycloak_realm.realm.id
  name      = each.value.name
  parent_id = keycloak_group.level_2[each.value.parent].id
  # attributes = lookup(each.value, "attributes", null)
}

locals {
  # Unified map of all groups for reference elsewhere
  keycloak_all_groups = merge(
    keycloak_group.level_0,
    keycloak_group.level_1,
    keycloak_group.level_2,
    keycloak_group.level_3
  )
}
