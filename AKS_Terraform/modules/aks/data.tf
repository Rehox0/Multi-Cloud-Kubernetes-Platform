data "azurerm_container_registry" "acr" {
  name                = "MultiCloudProjectACR"
  resource_group_name = "Multi-Cloud-Project-bootstrap-rg"
}

data "azurerm_resources" "aks_vmss" {
  resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group
  type                = "Microsoft.Compute/virtualMachineScaleSets"
}
