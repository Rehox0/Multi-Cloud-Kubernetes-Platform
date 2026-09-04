output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "jumpbox_subnet_id" {
  value = azurerm_subnet.jumpbox.id
}

