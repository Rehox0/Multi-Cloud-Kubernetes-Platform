#State SA + container (AWS S3 + DynamoDB)    
output "storage_account_name" {
  value       = azurerm_storage_account.bootstrap.name
  description = "Storage Account name for Terraform state"
}

output "storage_container_name" {
  value       = azurerm_storage_container.bootstrap.name
  description = "Storage Container name for Terraform state"
}

output "storage_account_id" {
  value = azurerm_storage_account.bootstrap.id
}

# ACR (AWS ECR)
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The URL that can be used to log into the container registry (e.g. acrallegro.azurecr.io)"
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

# GitHub Actions Identities & OIDC (AWS IAM Roles + OIDC Provider)
output "github_actions_client_id_dev" {
  value       = azurerm_user_assigned_identity.gha_dev.client_id
  description = "Client ID used by GitHub Actions in `azure/login` action for Dev"
}

output "github_actions_client_id_prod" {
  value       = azurerm_user_assigned_identity.gha_prod.client_id
  description = "Client ID used by GitHub Actions in `azure/login` action for Prod"
}