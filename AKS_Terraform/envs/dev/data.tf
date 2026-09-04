data "azurerm_resources" "aks_private_dns_zone" {
  resource_group_name = module.aks.node_resource_group

  type = "Microsoft.Network/privateDnsZones"
}

data "azurerm_private_dns_zone" "aks" {
  name                = data.azurerm_resources.aks_private_dns_zone.resources[0].name
  resource_group_name = module.aks.node_resource_group
}