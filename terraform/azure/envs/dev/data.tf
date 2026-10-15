data "azurerm_client_config" "current" {}

data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"

  config = {
    resource_group_name  = "Multi-Cloud-Project-bootstrap-rg"
    storage_account_name = "tfstate2027aks"
    container_name       = "multicloudproject2027"
    key                  = "envs/bootstrap/terraform.tfstate"
  }
}