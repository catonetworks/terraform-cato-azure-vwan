terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
    cato = {
      source  = "CatoNetworks/cato"
      version = "~> 0.0.24" # Use a version compatible with the module
    }
    random = {
      source = "hashicorp/random"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.5"
    }
  }
}