terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 5.7.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.0"
    }
  }

  required_version = ">= 1.9"
}

provider "keycloak" {
  realm     = "master"
  client_id = var.keycloak_client_id
  username  = var.keycloak_username
  password  = var.keycloak_password
  url       = var.keycloak_url
}
