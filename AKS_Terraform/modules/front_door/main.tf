resource "azurerm_private_link_service" "front_door" {
  name                = "${lower(replace(var.project_name, "-", ""))}-frontdoor-pls"
  location            = data.azurerm_lb.aks_gateway.location
  resource_group_name = var.resource_group_name

  load_balancer_frontend_ip_configuration_ids = [
    local.lb_frontend.id
  ]

  visibility_subscription_ids = [
    data.azurerm_client_config.current.subscription_id
  ]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address_version = "IPv4"
    subnet_id                  = var.private_link_subnet_id
    primary                    = true
  }

  tags = var.common_tags
}

resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "${var.project_name}-frontdoor"
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"

  response_timeout_seconds = 120

  tags = var.common_tags

  depends_on = [
    azurerm_private_link_service.front_door
  ]
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "${lower(replace(var.project_name, "-", ""))}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  enabled = true
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "${lower(replace(var.project_name, "-", ""))}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  session_affinity_enabled = false

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/api/health"
    protocol            = "Http"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  name                          = "${lower(replace(var.project_name, "-", ""))}-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id

  enabled = true
  certificate_name_check_enabled = true

  host_name = local.lb_frontend.private_ip_address

  http_port  = 80
  https_port = 443

  origin_host_header = local.lb_frontend.private_ip_address

  priority = 1
  weight   = 1000

  private_link {
    request_message = "Azure Front Door access to private AKS Cilium Gateway"

    location = var.private_link_location

    private_link_target_id = azurerm_private_link_service.front_door.id
  }

  depends_on = [
    azurerm_private_link_service.front_door
  ]
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "${lower(replace(var.project_name, "-", ""))}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.main.id
  ]

  enabled = true

  forwarding_protocol = "HttpOnly"

  patterns_to_match = [
    "/*"
  ]

  supported_protocols = [
    "Http",
    "Https"
  ]

  https_redirect_enabled = true

  link_to_default_domain = true

  depends_on = [
    azurerm_cdn_frontdoor_origin.main
  ]
}