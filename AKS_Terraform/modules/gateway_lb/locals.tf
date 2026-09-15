locals {
  aks_vmss_network_profile = data.azapi_resource.aks_vmss.output.properties.virtualMachineProfile.networkProfile

  gateway_network_interface_config = merge(
    local.aks_vmss_network_profile.networkInterfaceConfigurations[0],
    {
      properties = merge(
        local.aks_vmss_network_profile.networkInterfaceConfigurations[0].properties,
        {
          ipConfigurations = [
            merge(
              local.aks_vmss_network_profile.networkInterfaceConfigurations[0].properties.ipConfigurations[0],
              {
                properties = merge(
                  local.aks_vmss_network_profile.networkInterfaceConfigurations[0].properties.ipConfigurations[0],
                  {
                    loadBalancerBackendAddressPools = [
                      {
                        id = azurerm_lb_backend_address_pool.gateway.id
                      }
                    ]
                  }
                )
              }
            )
          ]
        }
      )
    }
  )
}