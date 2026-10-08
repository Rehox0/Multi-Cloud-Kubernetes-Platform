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
  value = aws_vpn_gateway.azure.id
}

output "azure_vpn_1_tunnel1_psk" {
  value     = aws_vpn_connection.azure_1.tunnel1_preshared_key
  sensitive = true
}

output "azure_vpn_1_tunnel2_psk" {
  value     = aws_vpn_connection.azure_1.tunnel2_preshared_key
  sensitive = true
}

output "azure_vpn_2_tunnel1_psk" {
  value     = aws_vpn_connection.azure_2.tunnel1_preshared_key
  sensitive = true
}

output "azure_vpn_2_tunnel2_psk" {
  value     = aws_vpn_connection.azure_2.tunnel2_preshared_key
  sensitive = true
}

output "azure_vpn_1_tunnel1_outside_ip" {
  value = aws_vpn_connection.azure_1.tunnel1_address
}

output "azure_vpn_1_tunnel2_outside_ip" {
  value = aws_vpn_connection.azure_1.tunnel2_address
}

output "azure_vpn_2_tunnel1_outside_ip" {
  value = aws_vpn_connection.azure_2.tunnel1_address
}

output "azure_vpn_2_tunnel2_outside_ip" {
  value = aws_vpn_connection.azure_2.tunnel2_address
}