data "azurerm_container_registry" "acr" {
  name                = "acrMultiCloudProject"
  resource_group_name = "Multi-Cloud-Project-bootstrap-rg"
}