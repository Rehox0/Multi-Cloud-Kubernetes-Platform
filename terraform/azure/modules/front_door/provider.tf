terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.3"
    }
  }
}