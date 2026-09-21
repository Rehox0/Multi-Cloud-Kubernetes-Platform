output "aks_vnet_id" {
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

output "private_link_subnet_id" {
  value = azurerm_subnet.private_link.id
}

# output "application_gateway_subnet_id" {
#   description = "Subnet ID for Application Gateway"
#   value       = azurerm_subnet.application_gateway.id
# }

# output "application_gateway_private_link_subnet_id" {
#   description = "Subnet ID for Application Gateway Private Link"
#   value       = azurerm_subnet.application_gateway_private_link.id
# }