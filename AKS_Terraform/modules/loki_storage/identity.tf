resource "azurerm_federated_identity_credential" "loki" {
  name = "${var.project_name}-loki-federated"

  user_assigned_identity_id = var.loki_identity_id

  issuer = var.aks_oidc_issuer_url

  subject = "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"

  audience = [
    "api://AzureADTokenExchange"
  ]
}

resource "azurerm_role_assignment" "loki_blob" {
  scope                = azurerm_storage_account.loki.id

  role_definition_name = "Storage Blob Data Contributor"

  principal_id = var.loki_identity_principal_id
}