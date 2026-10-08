resource "azurerm_federated_identity_credential" "backend_eso" {
  name = "backend-eso"

  user_assigned_identity_id = data.terraform_remote_state.bootstrap.outputs.backend_identity_id

  issuer = module.aks.oidc_issuer_url

  subject = "system:serviceaccount:backend-ns:backend"

  audience = [
    "api://AzureADTokenExchange"
  ]
}

resource "azurerm_federated_identity_credential" "eks_backend" {
  name = "eks-backend"

  user_assigned_identity_id = module.identity.eks_backend_identity_id

  issuer = "https://oidc.eks.eu-central-1.amazonaws.com/id/156C5E1A9B08008264178A5BA281981A"

  subject = "system:serviceaccount:backend-ns:backend"

  audience = [
    "api://AzureADTokenExchange"
  ]
}