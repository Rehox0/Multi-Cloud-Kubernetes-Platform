resource "azurerm_user_assigned_identity" "backend" {
  name                = "${var.project_name}-backend-identity"
  resource_group_name = azurerm_resource_group.bootstrap.name
  location            = azurerm_resource_group.bootstrap.location

  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}