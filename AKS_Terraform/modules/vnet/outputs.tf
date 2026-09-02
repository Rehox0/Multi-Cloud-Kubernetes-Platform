output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "aks_subnets" {
  value = azurerm_subnet.aks[*].id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.main.id
}

output "nat_public_ip" {
  value = azurerm_public_ip.nat.ip_address
}

output "jumpbox_subnet_id" {
  description = "Subnet ID for the jumpbox"
  value       = azurerm_subnet.jumpbox.id
}