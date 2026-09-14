resource "azurerm_lb" "main" {
  name                = "${var.project_name}-gateway-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "gateway-private"
    subnet_id                     = var.aks_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.common_tags
}