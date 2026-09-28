resource "random_password" "administrator" {
  length  = 32
  special = false
}

resource "azurerm_key_vault_secret" "administrator_password" {
  name         = "postgresql-admin-password"
  value        = random_password.administrator.result
  key_vault_id = var.key_vault_id

  content_type = "PostgreSQL administrator password"

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "host" {
  name         = "postgresql-host"
  value        = azurerm_postgresql_flexible_server.main.fqdn
  key_vault_id = var.key_vault_id

  content_type = "PostgreSQL host"

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "port" {
  name         = "postgresql-port"
  value        = var.postgresql_port
  key_vault_id = var.key_vault_id

  content_type = "PostgreSQL port"

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "database" {
  name         = "postgresql-database"
  value        = azurerm_postgresql_flexible_server_database.app.name
  key_vault_id = var.key_vault_id

  content_type = "PostgreSQL database"

  tags = var.common_tags
}

resource "azurerm_key_vault_secret" "username" {
  name         = "postgresql-username"
  value        = var.postgresql_administrator_login
  key_vault_id = var.key_vault_id

  content_type = "PostgreSQL username"

  tags = var.common_tags
}
