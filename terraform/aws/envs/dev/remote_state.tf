data "terraform_remote_state" "azure" {
  backend = "azurerm"

  config = {
    resource_group_name  = "Multi-Cloud-Project-bootstrap-rg"
    storage_account_name = "tfstate2027aks"
    container_name       = "multicloudproject2027"
    key                  = "envs/dev/aks/terraform.tfstate"
  }
}