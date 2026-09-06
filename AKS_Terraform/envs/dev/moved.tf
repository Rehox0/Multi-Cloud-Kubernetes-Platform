moved {
  from = module.vnet_jumpbox.azurerm_virtual_network.main
  to   = module.networking.azurerm_virtual_network.jumpbox
}

moved {
  from = module.vnet_jumpbox.azurerm_subnet.jumpbox
  to   = module.networking.azurerm_subnet.jumpbox
}