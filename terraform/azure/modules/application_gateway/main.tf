# resource "azurerm_public_ip" "main" {
#   name                = "${var.project_name}-appgw-pip"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = var.common_tags
# }

# resource "azurerm_application_gateway" "main" {
#   name                = "${var.project_name}-appgw"
#   resource_group_name = var.resource_group_name
#   location            = var.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 1
#   }

#   gateway_ip_configuration {
#     name      = "appgw-ip-config"
#     subnet_id = var.application_gateway_subnet_id
#   }

#   frontend_ip_configuration {
#     name                 = "appgw-public-frontend"
#     public_ip_address_id = azurerm_public_ip.main.id
#     private_link_configuration_name = "frontdoor-private-link"
#   }

#   private_link_configuration {
#     name = "frontdoor-private-link"

#     ip_configuration {
#       name                          = "frontdoor-private-link-ip"
#       subnet_id                     = var.application_gateway_private_link_subnet_id
#       private_ip_address_allocation = "Dynamic"
#       primary                       = true
#     }
#   }

#   frontend_port {
#     name = "http"
#     port = 80
#   }

#   backend_address_pool {
#     name = "cilium-gateway"
#   }

#   backend_http_settings {
#     name                  = "cilium-http"
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 30
#   }

#   probe {
#     name                                      = "cilium-health"
#     protocol                                  = "Http"
#     path                                      = "/api/health"
#     interval                                  = 30
#     timeout                                   = 10
#     unhealthy_threshold                       = 3
#     pick_host_name_from_backend_http_settings = true

#     match {
#       status_code = ["200-399"]
#     }
#   }

#   http_listener {
#     name                           = "http-listener"
#     frontend_ip_configuration_name = "appgw-public-frontend"
#     frontend_port_name             = "http"
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = "cilium"
#     priority                   = 100
#     rule_type                  = "Basic"
#     http_listener_name         = "http-listener"
#     backend_address_pool_name  = "cilium-gateway"
#     backend_http_settings_name = "cilium-http"
#   } 

#   tags = var.common_tags
# }