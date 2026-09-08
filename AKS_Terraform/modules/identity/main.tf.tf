resource "azurerm_user_assigned_identity" "backend" {
  name                = "${var.project_name}-backend-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-backend-identity"
  })
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.project_name}-aks-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aks-identity"
  })
}

resource "azurerm_role_assignment" "backend_keyvault" {
  scope                = var.backend_keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.backend.principal_id
}

resource "azurerm_role_assignment" "aks_private_dns" {
  scope                = var.aks_private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.aks_vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "user_keyvault_secrets_officer" {
  scope                = var.backend_keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.user_object_id
}
