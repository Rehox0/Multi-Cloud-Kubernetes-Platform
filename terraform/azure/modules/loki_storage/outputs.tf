output "storage_account_id" {
  description = "Resource ID of the Loki Storage Account"
  value       = azurerm_storage_account.loki.id
}

output "storage_account_name" {
  description = "Name of the Loki Storage Account"
  value       = azurerm_storage_account.loki.name
}

output "primary_blob_endpoint" {
  description = "Primary Blob endpoint of the Loki Storage Account"
  value       = azurerm_storage_account.loki.primary_blob_endpoint
}

output "chunks_container_name" {
  description = "Loki chunks Blob container"
  value       = azurerm_storage_container.chunks.name
}

output "ruler_container_name" {
  description = "Loki ruler Blob container"
  value       = azurerm_storage_container.ruler.name
}

output "admin_container_name" {
  description = "Loki admin Blob container"
  value       = azurerm_storage_container.admin.name
}
