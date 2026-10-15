data "azurerm_container_registry" "acr" {
  name                = "MultiCloudProjectACR1"
  resource_group_name = "Multi-Cloud-Project-bootstrap-rg"
}
