resource "azurerm_container_registry" "acr" {
  name                = replace("${var.project_name}ACR", "-", "")
  resource_group_name = azurerm_resource_group.bootstrap.name
  location            = azurerm_resource_group.bootstrap.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}