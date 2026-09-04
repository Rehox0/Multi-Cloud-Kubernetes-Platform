# ============================================================
# Virtual Network
# ============================================================

resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [var.vnet_cidr]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vnet"
  })
}

# ============================================================
# AKS Subnets
# ============================================================

resource "azurerm_subnet" "aks" {
  count = length(var.aks_subnet_cidrs)

  name = "${var.project_name}-aks-subnet-${count.index + 1}"

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.aks_subnet_cidrs[count.index]
  ]
}

# ============================================================
# Public IP for NAT Gateway
# ============================================================

resource "azurerm_public_ip" "nat" {
  name = "${var.project_name}-nat-ip"

  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nat-ip"
  })
}

# ============================================================
# NAT Gateway
# ============================================================

resource "azurerm_nat_gateway" "main" {
  name = "${var.project_name}-nat"

  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = "Standard"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nat"
  })
}

# Attach Public IP to NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# ============================================================
# NAT Gateway -> AKS Subnets
# ============================================================

resource "azurerm_subnet_nat_gateway_association" "aks" {
  count = length(azurerm_subnet.aks)

  subnet_id      = azurerm_subnet.aks[count.index].id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
