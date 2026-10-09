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

  issuer = data.terraform_remote_state.aws.outputs.eks_oidc_url

  subject = "system:serviceaccount:backend-ns:backend"

  audience = [
    "api://AzureADTokenExchange"
  ]
}