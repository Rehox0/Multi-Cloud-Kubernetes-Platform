resource "azurerm_traffic_manager_profile" "main" {
  name                   = "${var.project_name}-traffic-manager"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = lower(replace("${var.project_name}-traffic", "-", ""))
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = var.health_probe_path
    expected_status_code_ranges  = ["200-399"]
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  tags = var.common_tags
}


resource "azurerm_traffic_manager_external_endpoint" "aws" {
  name                 = "aws-cloudfront"
  profile_id           = azurerm_traffic_manager_profile.main.id

  target               = var.aws_cloudfront_hostname
  priority             = 1
  weight               = 100
  enabled              = true
}


resource "azurerm_traffic_manager_external_endpoint" "azure" {
  name                 = "azure-frontdoor"
  profile_id           = azurerm_traffic_manager_profile.main.id
  
  target               = var.azure_frontdoor_hostname
  priority             = 2
  weight               = 100
  enabled              = true
}