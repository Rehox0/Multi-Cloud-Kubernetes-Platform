
resource "random_password" "postgresql" {
  length  = 32
  special = false
}

resource "terraform_data" "grafana_credentials" {
  provisioner "local-exec" {
    command = "${path.module}/../../scripts/create-grafana-credentials.sh"

    environment = {
      KEY_VAULT_NAME = azurerm_key_vault.backend.name
    }
  }
}
