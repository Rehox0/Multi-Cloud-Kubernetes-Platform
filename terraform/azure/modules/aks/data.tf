data "azurerm_container_registry" "acr" {
  name                = "MultiCloudProjectACR"
  resource_group_name = "Multi-Cloud-Project-bootstrap-rg"
}
