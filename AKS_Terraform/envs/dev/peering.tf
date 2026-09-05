resource "azurerm_virtual_network_peering" "aks_to_jumpbox" {
  name = "${var.project_name}-aks-to-jumpbox"

  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = module.vnet.vnet_name

  remote_virtual_network_id = module.vnet_jumpbox.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "jumpbox_to_aks" {
  name = "${var.project_name}-jumpbox-to-aks"

  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = module.vnet_jumpbox.vnet_name

  remote_virtual_network_id = module.vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "jumpbox" {
  name = "${var.project_name}-jumpbox-dns"

  private_dns_zone_id   = data.azurerm_private_dns_zone.aks.id
  virtual_network_id = module.vnet_jumpbox.vnet_id
}