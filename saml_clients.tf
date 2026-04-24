resource "keycloak_saml_client" "saml_clients" {
  for_each = {
    for saml_client in var.keycloak_saml_clients :
    saml_client.name => saml_client
  }
  realm_id  = keycloak_realm.realm.id
  client_id = lower(replace(each.value.name, " ", "-"))

  name        = each.value.name
  description = lookup(each.value, "description", null)
  # Access Settings
  root_url            = each.value.root_url
  base_url            = each.value.base_url
  valid_redirect_uris = lookup(each.value, "valid_redirect_uris", ["${each.value.base_url}/*"])
  # TODO: Add Valid post logout redirect URIs manually: not yet available on provider

  # SAML Capabilities
  master_saml_processing_url = each.value.master_saml_processing_url
  name_id_format             = each.value.name_id_format
  include_authn_statement    = each.value.include_authn_statement
  force_post_binding         = each.value.force_post_binding

  # Signature and Encryption
  sign_documents      = each.value.sign_documents
  sign_assertions     = each.value.sign_assertions
  signature_algorithm = lookup(each.value, "signature_algorithm", null)
  # TODO: set metadata descriptor for the moment manual: Not yet implemented in the provider
  front_channel_logout = each.value.front_channel_logout

  depends_on = [
    time_sleep.after_users
  ]
}

resource "time_sleep" "after_saml_clients" {
  for_each = keycloak_saml_client.saml_clients

  depends_on = [
    keycloak_saml_client.saml_clients
  ]

  create_duration = "30s"
}

locals {
  saml_user_attribute_mappers = flatten([
    for client in var.keycloak_saml_clients : [
      for mapper in coalesce(client.saml_attribute_mappers, []) : {
        client_name                = client.name
        name                       = mapper.name
        user_attribute             = mapper.user_attribute
        saml_attribute_name        = mapper.saml_attribute_name
        saml_attribute_name_format = mapper.saml_attribute_name_format
      }
    ]
  ])
}

resource "keycloak_saml_user_attribute_protocol_mapper" "saml_user_attribute_mappers" {
  for_each = {
    for mapper in local.saml_user_attribute_mappers :
    "${mapper.client_name}-${mapper.name}" => mapper
  }
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_saml_client.saml_clients[each.value.client_name].id
  name      = each.value.name

  user_attribute             = each.value.user_attribute
  saml_attribute_name        = each.value.saml_attribute_name
  saml_attribute_name_format = each.value.saml_attribute_name_format
  depends_on = [
    time_sleep.after_saml_clients
  ]
}
