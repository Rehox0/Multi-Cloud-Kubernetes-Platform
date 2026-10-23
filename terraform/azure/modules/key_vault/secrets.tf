
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

  triggers_replace = [
    var.user_keyvault_secrets_officer_role_assignment_id
  ]
}
