resource "azurerm_public_ip" "vpn_gateway_1" {
  name                = "${var.project_name}-vpn-gateway-pip-1"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpn-gateway-pip-1"
  })
}

resource "azurerm_public_ip" "vpn_gateway_2" {
  name                = "${var.project_name}-vpn-gateway-pip-2"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpn-gateway-pip-2"
  })
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = "${var.project_name}-vpn-gateway"
  location            = var.jumpbox_network.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  sku           = "VpnGw2AZ"

  ip_configuration {
    name                          = "vpn-gateway-ipconfig-1"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  ip_configuration {
    name                          = "vpn-gateway-ipconfig-2"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
  
  bgp_settings {
    asn = 65515

    peering_addresses {
      ip_configuration_name = "vpn-gateway-ipconfig-1"

      apipa_addresses = [
        var.vpn_gateway_bgp_apipa_addresses[0],
        var.vpn_gateway_bgp_apipa_addresses[1]
      ]
    }

    peering_addresses {
      ip_configuration_name = "vpn-gateway-ipconfig-2"

      apipa_addresses = [
        var.vpn_gateway_bgp_apipa_addresses[2],
        var.vpn_gateway_bgp_apipa_addresses[3]
      ]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpn-gateway"
  })
}