output "profile_id" {
  description = "Azure Traffic Manager profile ID"
  value       = azurerm_traffic_manager_profile.main.id
}


output "profile_name" {
  description = "Azure Traffic Manager profile name"
  value       = azurerm_traffic_manager_profile.main.name
}


output "fqdn" {
  description = "Azure Traffic Manager DNS hostname"
  value       = azurerm_traffic_manager_profile.main.fqdn
}


output "aws_endpoint_id" {
  description = "AWS CloudFront Traffic Manager endpoint ID"
  value       = azurerm_traffic_manager_external_endpoint.aws.id
}


output "azure_endpoint_id" {
  description = "Azure Front Door Traffic Manager endpoint ID"
  value       = azurerm_traffic_manager_external_endpoint.azure.id
}