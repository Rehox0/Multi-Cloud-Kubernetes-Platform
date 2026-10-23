resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "${var.project_name}-frontdoor"
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"

  response_timeout_seconds = 120

  tags = var.common_tags
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

  enabled                        = true
  certificate_name_check_enabled = true

  host_name          = data.azurerm_private_link_service.gateway.alias
  origin_host_header = data.azurerm_private_link_service.gateway.alias

  http_port  = 80
  https_port = 443


  priority = 1
  weight   = 1000

  private_link {
    location               = var.location
    private_link_target_id = data.azurerm_private_link_service.gateway.id
    request_message        = "Azure Front Door private connectivity to Cilium Gateway"
  }

  depends_on = [
    data.azurerm_private_link_service.gateway
  ]
}

resource "azurerm_cdn_frontdoor_rule_set" "api_no_cache" {

  name                     = "ApiNoCache"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_rule" "api_no_cache" {
  name                      = "BypassApiCache"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.api_no_cache.id
  order                     = 1
  behaviour_on_match        = "Continue"

  conditions {
    request_path {
      operator = "BeginsWith"
      values   = ["/api/"]
    }
  }

  actions {
    route_configuration_override {
      caching {
        behaviour = "Disabled"
      }
    }
  }

  depends_on = [
    azurerm_cdn_frontdoor_origin_group.main,
    azurerm_cdn_frontdoor_origin.main
  ]
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "${lower(replace(var.project_name, "-", ""))}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.main.id
  ]

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.app.id
  ]

  cdn_frontdoor_rule_set_ids = [
    azurerm_cdn_frontdoor_rule_set.api_no_cache.id
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

resource "azurerm_cdn_frontdoor_custom_domain" "app" {

  name = "app-domain"

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  dns_zone_id = null

  host_name = var.host_name

  tls {
    certificate_type = "ManagedCertificate"
  }
}