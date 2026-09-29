resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${lower(var.project_name)}-postgresql"
  resource_group_name = var.resource_group_name
  location            = var.location

  version = "18"
  zone    = "1"

  delegated_subnet_id           = var.subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false

  administrator_login    = var.postgresql_admin_login
  administrator_password = var.postgresql_admin_password

  storage_mb = var.storage_mb
  sku_name   = var.sku_name

  backup_retention_days = var.backup_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-postgresql"
  })
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}


