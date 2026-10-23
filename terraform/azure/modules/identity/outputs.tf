output "aks_identity_id" {
  value = azurerm_user_assigned_identity.aks.id
}

output "aks_identity_client_id" {
  value = azurerm_user_assigned_identity.aks.client_id
}

output "aks_identity_principal_id" {
  value = azurerm_user_assigned_identity.aks.principal_id
}

output "user_keyvault_secrets_officer_role_assignment_id" {
  value = azurerm_role_assignment.user_keyvault_secrets_officer.id
}

output "eks_backend_identity_id" {
  value = azurerm_user_assigned_identity.eks_backend.id
}

output "eks_backend_identity_client_id" {
  value = azurerm_user_assigned_identity.eks_backend.client_id
}

output "eks_backend_identity_principal_id" {
  value = azurerm_user_assigned_identity.eks_backend.principal_id
}