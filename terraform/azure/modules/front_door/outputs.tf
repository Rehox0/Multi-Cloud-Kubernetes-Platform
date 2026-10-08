output "profile_id" {
  description = "Azure Front Door profile ID"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "origin_group_id" {
  description = "Azure Front Door origin group ID"
  value       = azurerm_cdn_frontdoor_origin_group.main.id
}

output "origin_id" {
  description = "Azure Front Door origin ID"
  value       = azurerm_cdn_frontdoor_origin.main.id
}

output "id" {
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