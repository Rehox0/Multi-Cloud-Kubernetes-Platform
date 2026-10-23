output "id" {
  value = azurerm_key_vault.backend.id
}

output "name" {
  value = azurerm_key_vault.backend.name
}

output "uri" {
  value = azurerm_key_vault.backend.vault_uri
}

output "postgresql_admin_password" {
  value     = random_password.postgresql.result
  sensitive = true
}