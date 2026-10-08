resource "aws_vpn_gateway" "azure" {
  vpc_id = aws_vpc.main.id

  amazon_side_asn = 64512

  tags = {
    Name = "${var.project_name}-azure-vpn-gateway"
  }
}

resource "aws_customer_gateway" "azure_1" {
  bgp_asn    = 65515
  ip_address = var.azure_vpn_gateway_public_ip_1
  type       = "ipsec.1"

  tags = {
    Name = "${var.project_name}-azure-cgw-1"
  }
}

resource "aws_customer_gateway" "azure_2" {
  bgp_asn    = 65515
  ip_address = var.azure_vpn_gateway_public_ip_2
  type       = "ipsec.1"

  tags = {
    Name = "${var.project_name}-azure-cgw-2"
  }
}

resource "aws_vpn_connection" "azure_1" {
  vpn_gateway_id      = aws_vpn_gateway.azure.id
  customer_gateway_id = aws_customer_gateway.azure_1.id

  type = "ipsec.1"

  static_routes_only = false

  tunnel1_inside_cidr = "169.254.21.0/30"
  tunnel2_inside_cidr = "169.254.22.0/30"

  tags = {
    Name = "${var.project_name}-azure-vpn-1"
  }
}

resource "aws_vpn_connection" "azure_2" {
  vpn_gateway_id      = aws_vpn_gateway.azure.id
  customer_gateway_id = aws_customer_gateway.azure_2.id

  type = "ipsec.1"

  static_routes_only = false

  tunnel1_inside_cidr = "169.254.21.4/30"
  tunnel2_inside_cidr = "169.254.22.4/30"

  tags = {
    Name = "${var.project_name}-azure-vpn-2"
  }
}
