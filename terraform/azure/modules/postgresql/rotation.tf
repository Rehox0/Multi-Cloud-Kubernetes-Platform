resource "terraform_data" "password_rotation" {
  provisioner "local-exec" {
    command = "${path.module}/../../scripts/rotate-postgresql-password.sh"

    environment = {
      KEY_VAULT_NAME = var.key_vault_name
      DB_SERVER      = azurerm_postgresql_flexible_server.main.name
      RESOURCE_GROUP = var.resource_group_name
    }
  }

  depends_on = [
    azurerm_postgresql_flexible_server.main,
    azurerm_postgresql_flexible_server_database.app
  ]
}