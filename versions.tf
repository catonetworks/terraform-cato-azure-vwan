terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
    cato = {
      source = "catonetworks/cato"
    }
  }
  required_version = ">= 0.13"
}