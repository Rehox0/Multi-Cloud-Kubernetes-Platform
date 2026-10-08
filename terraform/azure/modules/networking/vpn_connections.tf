resource "azurerm_local_network_gateway" "aws_vpn_1_tunnel_1" {
  name                = "${var.project_name}-aws-vpn-1-tunnel-1"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  gateway_address = var.aws_vpn_tunnel_outside_ips.vpn_1_tunnel_1

  bgp_settings {
    asn                 = 64512
    bgp_peering_address = "169.254.21.1"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-1-tunnel-1"
  })
}

resource "azurerm_local_network_gateway" "aws_vpn_1_tunnel_2" {
  name                = "${var.project_name}-aws-vpn-1-tunnel-2"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  gateway_address = var.aws_vpn_tunnel_outside_ips.vpn_1_tunnel_2

  bgp_settings {
    asn                 = 64512
    bgp_peering_address = "169.254.22.1"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-1-tunnel-2"
  })
}

resource "azurerm_local_network_gateway" "aws_vpn_2_tunnel_1" {
  name                = "${var.project_name}-aws-vpn-2-tunnel-1"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  gateway_address = var.aws_vpn_tunnel_outside_ips.vpn_2_tunnel_1

  bgp_settings {
    asn                 = 64512
    bgp_peering_address = "169.254.21.5"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-2-tunnel-1"
  })
}

resource "azurerm_local_network_gateway" "aws_vpn_2_tunnel_2" {
  name                = "${var.project_name}-aws-vpn-2-tunnel-2"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  gateway_address = var.aws_vpn_tunnel_outside_ips.vpn_2_tunnel_2

  bgp_settings {
    asn                 = 64512
    bgp_peering_address = "169.254.22.5"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-2-tunnel-2"
  })
}

resource "azurerm_virtual_network_gateway_connection" "aws_vpn_1_tunnel_1" {
  name                = "${var.project_name}-aws-vpn-1-tunnel-1"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_vpn_1_tunnel_1.id

  bgp_enabled = true

  shared_key = var.aws_vpn_tunnel_psks.vpn_1_tunnel_1

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-1-tunnel-1"
  })
}

resource "azurerm_virtual_network_gateway_connection" "aws_vpn_1_tunnel_2" {
  name                = "${var.project_name}-aws-vpn-1-tunnel-2"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_vpn_1_tunnel_2.id

  bgp_enabled = true

  shared_key = var.aws_vpn_tunnel_psks.vpn_1_tunnel_2

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-1-tunnel-2"
  })
}

resource "azurerm_virtual_network_gateway_connection" "aws_vpn_2_tunnel_1" {
  name                = "${var.project_name}-aws-vpn-2-tunnel-1"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_vpn_2_tunnel_1.id

  bgp_enabled = true

  shared_key = var.aws_vpn_tunnel_psks.vpn_2_tunnel_1

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-2-tunnel-1"
  })
}

resource "azurerm_virtual_network_gateway_connection" "aws_vpn_2_tunnel_2" {
  name                = "${var.project_name}-aws-vpn-2-tunnel-2"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_vpn_2_tunnel_2.id

  bgp_enabled = true

  shared_key = var.aws_vpn_tunnel_psks.vpn_2_tunnel_2

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpn-2-tunnel-2"
  })
}
