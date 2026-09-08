resource "azurerm_federated_identity_credential" "backend_eso" {
  name = "backend-eso"

  user_assigned_identity_id = module.identity.backend_identity_id

  issuer = module.aks.oidc_issuer_url

  subject = "system:serviceaccount:backend-ns:backend"

  audience = [
    "api://AzureADTokenExchange"
  ]
}