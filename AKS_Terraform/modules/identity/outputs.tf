output "aks_identity_id" {
  value = azurerm_user_assigned_identity.aks.id
}

output "aks_identity_client_id" {
  value = azurerm_user_assigned_identity.aks.client_id
}

output "aks_identity_principal_id" {
  value = azurerm_user_assigned_identity.aks.principal_id
}
