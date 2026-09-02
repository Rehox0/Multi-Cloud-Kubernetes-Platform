locals {
  github_repo_slug = "${var.github_owner}/${var.github_repository}"
}

data "azurerm_client_config" "current" {}

################################################################################
# DEV IDENTITY & FEDERATION
################################################################################

resource "azurerm_user_assigned_identity" "gha_dev" {
  name                = "id-gha-dev-${var.project_name}"
  resource_group_name = azurerm_resource_group.bootstrap.name
  location            = azurerm_resource_group.bootstrap.location

  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_federated_identity_credential" "gha_dev_env" {
  name                = "gha-dev-env"
  resource_group_name = azurerm_resource_group.bootstrap.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.gha_dev.id
  subject             = "repo:${var.github_oidc_repository}:environment:dev"
}

################################################################################
# PROD IDENTITY & FEDERATION
################################################################################

# resource "azurerm_user_assigned_identity" "gha_prod" {
#   name                = "id-gha-prod-${var.project_name}"
#   resource_group_name = azurerm_resource_group.bootstrap.name
#   location            = azurerm_resource_group.bootstrap.location

#   tags = {
#     Project     = var.project_name
#     Environment = "prod"
#     ManagedBy   = "Terraform"
#   }
# }

# resource "azurerm_federated_identity_credential" "gha_prod_env" {
#   name                = "gha-prod-env"
#   resource_group_name = azurerm_resource_group.bootstrap.name
#   audience            = ["api://AzureADTokenExchange"]
#   issuer              = "https://token.actions.githubusercontent.com"
#   parent_id           = azurerm_user_assigned_identity.gha_prod.id
#   subject             = "repo:${local.github_repo_slug}:environment:prod"
# }

################################################################################
# GITHUB SECRETS
################################################################################

resource "github_actions_environment_secret" "dev_client_id" {
  repository      = var.github_repository
  environment     = "dev"
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.gha_dev.client_id
}

# resource "github_actions_environment_secret" "prod_client_id" {
#   repository      = var.github_repository
#   environment     = "prod"
#   secret_name     = "AZURE_CLIENT_ID"
#   plaintext_value = azurerm_user_assigned_identity.gha_prod.client_id
# }

resource "github_actions_secret" "azure_tenant_id" {
  repository      = var.github_repository
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = azurerm_user_assigned_identity.gha_dev.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = var.github_repository
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_role_assignment" "gha_subscription_reader" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.gha_dev.principal_id
}

resource "azurerm_role_assignment" "gha_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.gha_dev.principal_id
}