resource "azurerm_lb" "main" {
  name                = "${var.project_name}-gateway-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "gateway-private"
    subnet_id                     = var.aks_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.common_tags
}

resource "azurerm_lb_backend_address_pool" "gateway" {
  name            = "gateway-backend-pool"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_lb_rule" "gateway" {
  name                           = "gateway"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = var.protocol
  frontend_port                  = var.gateway_frontend_port
  backend_port                   = var.gateway_node_port
  frontend_ip_configuration_name = "gateway-private"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.gateway.id]
  probe_id                       = azurerm_lb_probe.gateway.id
}

resource "azurerm_lb_probe" "gateway" {
  name            = "gateway-probe"
  loadbalancer_id = azurerm_lb.main.id
  protocol        = var.protocol
  port            = var.gateway_node_port
}

resource "azapi_update_resource" "gateway_vmss_backend_pool" {
  type        = "Microsoft.Compute/virtualMachineScaleSets@2024-07-01"
  resource_id = var.aks_vmss_id

  body = {
    properties = {
      virtualMachineProfile = {
        networkProfile = merge(
          local.aks_vmss_network_profile,
          {
            networkInterfaceConfigurations = [
              local.gateway_network_interface_config
            ]
          }
        )
      }
    }
  }

  depends_on = [
    azurerm_lb_backend_address_pool.gateway
  ]
}