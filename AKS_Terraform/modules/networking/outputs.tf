output "vnet_id" {
  value = azurerm_virtual_network.aks.id
}

output "vnet_name" {
  value = azurerm_virtual_network.aks.name
}

output "jumpbox_subnet_id" {
  value = azurerm_subnet.jumpbox.id
}

output "aks_subnets" {
  value = azurerm_subnet.aks[*].id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.aks.id
}

output "nat_public_ip" {
  value = azurerm_public_ip.nat.ip_address
}

output "aks_private_dns_zone_id" {
  description = "ID of the AKS private DNS zone"
  value       = azurerm_private_dns_zone.aks.id
}
