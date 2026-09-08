data "azurerm_client_config" "current" {}

data "azurerm_lb" "aks_gateway" {
  name                = "kubernetes-internal"
  resource_group_name = var.aks_node_resource_group
}

locals {
  lb_frontends = [
    for frontend in data.azurerm_lb.aks_gateway.frontend_ip_configuration :
    frontend
    if frontend.subnet_id == var.aks_subnet_id
  ]

  lb_frontend = one(local.lb_frontends)
}