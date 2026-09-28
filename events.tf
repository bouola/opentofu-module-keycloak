resource "keycloak_realm_events" "realm_events" {
  count    = var.keycloak_realm.events != null ? 1 : 0
  realm_id = keycloak_realm.realm.id

  events_enabled      = var.keycloak_realm.events.events_enabled
  events_expiration   = var.keycloak_realm.events.events_expiration
  enabled_event_types = var.keycloak_realm.events.enabled_event_types

  admin_events_enabled         = var.keycloak_realm.events.admin_events_enabled
  admin_events_details_enabled = var.keycloak_realm.events.admin_events_details_enabled

  events_listeners = var.keycloak_realm.events.events_listeners

  depends_on = [
    time_sleep.after_realm
  ]
}
