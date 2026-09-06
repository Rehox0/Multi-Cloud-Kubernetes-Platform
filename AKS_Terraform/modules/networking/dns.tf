resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name = "${var.project_name}-aks-dns"

  private_dns_zone_id = azurerm_private_dns_zone.aks.id
  virtual_network_id  = azurerm_virtual_network.aks.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "jumpbox" {
  name = "${var.project_name}-jumpbox-dns"

  private_dns_zone_id = azurerm_private_dns_zone.aks.id
  virtual_network_id  = azurerm_virtual_network.jumpbox.id
}