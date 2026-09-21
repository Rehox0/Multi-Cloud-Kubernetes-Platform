data "azurerm_client_config" "current" {}

data "azurerm_private_link_service" "gateway" {
  name                = "${var.project_name}-gateway-pls"
  resource_group_name = var.aks_node_resource_group
}
