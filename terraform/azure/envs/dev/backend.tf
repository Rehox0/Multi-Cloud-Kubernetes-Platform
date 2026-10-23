terraform {
  backend "azurerm" {
    resource_group_name  = "Multi-Cloud-Project-bootstrap-rg"
    storage_account_name = "tfstate2027aks"
    container_name       = "multicloudproject2027"
    key                  = "envs/dev/aks/terraform.tfstate"
  }
}