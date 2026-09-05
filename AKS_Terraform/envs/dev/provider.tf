terraform {
  required_version = ">= 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.4"
    }
  
    azapi = {
      source  = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "azapi" {}