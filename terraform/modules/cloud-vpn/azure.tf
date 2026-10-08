resource "azurerm_public_ip" "vpn_gateway_1" {
  name                = "${var.project_name}-vpn-gateway-pip-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vpn_gateway_2" {
  name                = "${var.project_name}-vpn-gateway-pip-2"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}