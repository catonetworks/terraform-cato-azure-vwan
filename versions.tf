terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.34.0"
    }
    cato = {
      source  = "CatoNetworks/cato"
      version = "~> 0.0.27" # Use a version compatible with the module
    }
    random = {
      source = "hashicorp/random"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4.0"
    }
  }
    required_version = ">= 1.4"
}