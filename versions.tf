terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 5.9.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.0"
    }
  }

  required_version = ">= 1.9"
}

# Client credentials grant when keycloak_client_secret is set and username/password are null,
# password grant otherwise
provider "keycloak" {
  realm         = "master"
  client_id     = var.keycloak_client_id
  client_secret = var.keycloak_client_secret
  username      = var.keycloak_username
  password      = var.keycloak_password
  url           = var.keycloak_url
}
