terraform {
  backend "azurerm" {
    resource_group_name  = "Multi-Cloud-Project-bootstrap-rg"
    storage_account_name = "sttfstate2026aks"
    container_name       = "multicloudprojecttfstate2026"
    key                  = "envs/dev/aks/terraform.tfstate"
  }
}