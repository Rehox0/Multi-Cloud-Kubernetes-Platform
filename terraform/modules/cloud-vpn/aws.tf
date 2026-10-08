resource "aws_vpn_gateway" "azure" {
  vpc_id = var.aws_vpc_id

  amazon_side_asn = 64512

  tags = {
    Name = "${var.project_name}-azure-vpn-gateway"
  }
}