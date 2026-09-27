locals {
  keycloak_user_profile_managed = var.keycloak_realm.user_profile != null

  # Built-in attributes with Keycloak default validators
  keycloak_user_profile_builtin_attributes = [
    {
      name         = "username"
      display_name = "$${username}"
      validators = {
        "length"                         = { min = "3", max = "255" }
        "username-prohibited-characters" = {}
        "up-username-not-idn-homograph"  = {}
      }
    },
    {
      name         = "email"
      display_name = "$${email}"
      validators = {
        "email"  = {}
        "length" = { max = "255" }
      }
    },
    {
      name         = "firstName"
      display_name = "$${firstName}"
      validators = {
        "length"                            = { max = "255" }
        "person-name-prohibited-characters" = {}
      }
    },
    {
      name         = "lastName"
      display_name = "$${lastName}"
      validators = {
        "length"                            = { max = "255" }
        "person-name-prohibited-characters" = {}
      }
    },
  ]

  keycloak_user_profile_attributes = local.keycloak_user_profile_managed ? concat(
    [
      for attribute in local.keycloak_user_profile_builtin_attributes : {
        name         = attribute.name
        display_name = attribute.display_name
        group        = null
        multi_valued = false
        # username is always required; its edition by users is governed by edit_username_allowed
        required_for_roles = attribute.name == "username" || contains(var.keycloak_realm.user_profile.required, attribute.name) ? ["user"] : []
        view               = ["admin", "user"]
        edit               = attribute.name == "username" || contains(var.keycloak_realm.user_profile.user_editable, attribute.name) ? ["admin", "user"] : ["admin"]
        validators         = attribute.validators
        annotations        = {}
      }
    ],
    var.keycloak_realm.user_profile.attributes
  ) : []
}

resource "keycloak_realm_user_profile" "user_profile" {
  count                      = local.keycloak_user_profile_managed ? 1 : 0
  realm_id                   = keycloak_realm.realm.id
  unmanaged_attribute_policy = var.keycloak_realm.user_profile.unmanaged_attribute_policy

  dynamic "attribute" {
    for_each = local.keycloak_user_profile_attributes
    content {
      name               = attribute.value.name
      display_name       = attribute.value.display_name
      group              = attribute.value.group
      multi_valued       = attribute.value.multi_valued
      required_for_roles = attribute.value.required_for_roles
      annotations        = attribute.value.annotations

      permissions {
        view = attribute.value.view
        edit = attribute.value.edit
      }

      dynamic "validator" {
        for_each = attribute.value.validators
        content {
          name   = validator.key
          config = validator.value
        }
      }
    }
  }

  dynamic "group" {
    for_each = var.keycloak_realm.user_profile.groups
    content {
      name                = group.value.name
      display_header      = group.value.display_header
      display_description = group.value.display_description
    }
  }

  depends_on = [
    time_sleep.after_realm
  ]
}
