resource "random_password" "grafana" {
  length  = 32
  special = false
}

resource "random_password" "postgresql" {
  length  = 32
  special = false
}

resource "azurerm_key_vault_secret" "grafana_admin_user" {
  name         = "grafana-admin-user"
  value        = var.grafana_admin_user
  key_vault_id = azurerm_key_vault.backend.id
  content_type = "Grafana admin user"

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "grafana_admin_password" {
  name         = "grafana-admin-password"
  value        = random_password.grafana.result
  key_vault_id = azurerm_key_vault.backend.id
  content_type = "Grafana admin password"

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  name         = "postgresql-admin-password"
  value        = random_password.postgresql.result
  key_vault_id = azurerm_key_vault.backend.id

  content_type = "PostgreSQL administrator password"

  tags = var.common_tags
}
