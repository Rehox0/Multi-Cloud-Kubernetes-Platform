resource "azurerm_user_assigned_identity" "jumpbox" {
  name                = "${var.project_name}-jumpbox-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.common_tags
}

resource "azurerm_role_assignment" "jumpbox_network_contributor" {
  scope                = var.aks_node_resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}

resource "azurerm_role_assignment" "jumpbox_aks_user" {
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}

resource "azurerm_role_assignment" "jumpbox_reader" {
  scope                = var.aks_node_resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}