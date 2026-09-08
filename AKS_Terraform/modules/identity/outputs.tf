output "aks_identity_id" {
  value = azurerm_user_assigned_identity.aks.id
}

output "aks_identity_client_id" {
  value = azurerm_user_assigned_identity.aks.client_id
}

output "aks_identity_principal_id" {
  value = azurerm_user_assigned_identity.aks.principal_id
}

output "backend_identity_id" {
  description = "Resource ID of the backend User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.backend.id
}

output "backend_identity_client_id" {
  description = "Client ID used by Kubernetes Workload Identity"
  value       = azurerm_user_assigned_identity.backend.client_id
}

output "backend_identity_principal_id" {
  description = "Principal ID of the backend User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.backend.principal_id
}

output "user_object_id" {
  description = "Object ID of the Azure user who should manage Key Vault secrets"
  value       = var.user_object_id
}
