output "profile_id" {
  description = "Azure Front Door profile ID"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "endpoint_id" {
  description = "Azure Front Door endpoint ID"
  value       = azurerm_cdn_frontdoor_endpoint.main.id
}

output "endpoint_hostname" {
  description = "Azure Front Door endpoint hostname"
  value       = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "origin_group_id" {
  description = "Azure Front Door origin group ID"
  value       = azurerm_cdn_frontdoor_origin_group.main.id
}

output "origin_id" {
  description = "Azure Front Door origin ID"
  value       = azurerm_cdn_frontdoor_origin.main.id
}

output "private_link_service_id" {
  description = "Private Link Service used by Azure Front Door"
  value       = azurerm_private_link_service.front_door.id
}

output "private_link_service_alias" {
  description = "Private Link Service alias"
  value       = azurerm_private_link_service.front_door.alias
}

output "origin_private_ip" {
  description = "Private IP of the AKS internal Load Balancer frontend"
  value       = local.lb_frontend.private_ip_address
}