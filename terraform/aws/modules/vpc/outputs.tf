output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "private_route_table_ids" {
  value = aws_route_table.private[*].id
}

output "vpn_gateway_id" {
  value       = try(aws_vpn_gateway.azure[0].id, null)
}

output "azure_vpn_1_tunnel1_psk" {
  value     = try(aws_vpn_connection.azure_1[0].tunnel1_preshared_key, null)
  sensitive = true
}

output "azure_vpn_1_tunnel2_psk" {
  value     = try(aws_vpn_connection.azure_1[0].tunnel2_preshared_key, null)
  sensitive = true
}

output "azure_vpn_2_tunnel1_psk" {
  value     = try(aws_vpn_connection.azure_2[0].tunnel1_preshared_key, null)
  sensitive = true
}

output "azure_vpn_2_tunnel2_psk" {
  value     = try(aws_vpn_connection.azure_2[0].tunnel2_preshared_key, null)
  sensitive = true
}

output "azure_vpn_1_tunnel1_outside_ip" {
  value = try(aws_vpn_connection.azure_1[0].tunnel1_address, null)
}

output "azure_vpn_1_tunnel2_outside_ip" {
  value = try(aws_vpn_connection.azure_1[0].tunnel2_address, null)
}

output "azure_vpn_2_tunnel1_outside_ip" {
  value = try(aws_vpn_connection.azure_2[0].tunnel1_address, null)
}

output "azure_vpn_2_tunnel2_outside_ip" {
  value = try(aws_vpn_connection.azure_2[0].tunnel2_address, null)
}