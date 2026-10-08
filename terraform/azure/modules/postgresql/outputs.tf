output "id" {
  description = "ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}