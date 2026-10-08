resource "azurerm_virtual_network_peering" "aks_to_jumpbox" {
  name = "${var.project_name}-aks-to-jumpbox"

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  remote_virtual_network_id = azurerm_virtual_network.jumpbox.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "jumpbox_to_aks" {
  name = "${var.project_name}-jumpbox-to-aks"

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.jumpbox.name

  remote_virtual_network_id = azurerm_virtual_network.aks.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}