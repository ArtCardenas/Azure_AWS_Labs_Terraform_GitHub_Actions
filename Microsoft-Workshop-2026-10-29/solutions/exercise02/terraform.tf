terraform {
  required_version = ">= 1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "core"
  resource_providers_to_register  = ["Microsoft.OperationalInsights"]
  storage_use_azuread             = true
}