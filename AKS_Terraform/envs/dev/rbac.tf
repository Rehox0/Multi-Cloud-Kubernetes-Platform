resource "azurerm_role_assignment" "jumpbox_aks_user" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.jumpbox.identity_principal_id
}