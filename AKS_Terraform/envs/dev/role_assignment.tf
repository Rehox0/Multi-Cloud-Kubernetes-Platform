resource "azurerm_role_assignment" "jumpbox_aks_user" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.jumpbox.identity_principal_id
}

resource "azurerm_role_assignment" "jumpbox_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = module.jumpbox.identity_principal_id
}