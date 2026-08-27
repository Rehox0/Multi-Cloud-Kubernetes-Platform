terraform {
  backend "azurerm" {
    resource_group_name  = "rg-Multi-Cloud-Kubernetes-Platform-bootstrap"
    storage_account_name = "sttfstate2026aks"
    container_name       = "allegroanalyticsakstfstate2026"
    key                  = "envs/dev/aks/terraform.tfstate"
  }
}