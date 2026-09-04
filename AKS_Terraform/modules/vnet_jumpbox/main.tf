resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-jumpbox-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [var.vnet_cidr]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox-vnet"
  })
}

resource "azurerm_subnet" "jumpbox" {
  name = "${var.project_name}-jumpbox-subnet"

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.jumpbox_subnet_cidr
  ]
}