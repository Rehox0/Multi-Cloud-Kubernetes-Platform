resource "azurerm_user_assigned_identity" "eks_backend" {
  name                = "${var.project_name}-eks-backend-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-eks-backend-identity"
  })
}

resource "azurerm_role_assignment" "eks_backend_keyvault" {
  scope                = var.backend_keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.eks_backend.principal_id
}