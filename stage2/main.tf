variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "DJANGO_SECRET_KEY_PROD" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.70.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "rg-acmp-final"
    storage_account_name = "acmp2400storageaccount"
    container_name = "big-tf-state-acmp2400"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "isaacfox-acr" {
  name = "isaacfoxacmp2400"
  resource_group_name = "rg-isaacfox"
  location = "Central US"
  sku = "Basic"
  admin_enabled = false
}

resource "azurerm_container_group" "isaacfox-aci" {
  name                = "acmp-isaacfox-aci"
  location            = "Central US"
  resource_group_name = "rg-isaacfox"
  ip_address_type     = "Public"
  dns_name_label      = "acmp-isaacfox-instance"
  os_type             = "Linux"

  container {
    name   = "final-app"
    image  = "isaacfoxacmp2400.azurecr.io/final:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8000
      protocol = "TCP"
      }

  secure_environment_variables = {
    DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY_PROD
    }
  }

    image_registry_credential {
      server = "isaacfoxacmp2400.azurecr.io"
      username = var .ARM_CLIENT_ID
      password = var .ARM_CLIENT_SECRET

      }
    }
