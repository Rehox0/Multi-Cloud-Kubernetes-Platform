output "vpn_gateway_public_ip_1" {
  value = module.networking.vpn_gateway_public_ip_1
}

output "vpn_gateway_public_ip_2" {
  value = module.networking.vpn_gateway_public_ip_2
}

output "eks_backend_identity_client_id" {
  value = module.identity.eks_backend_identity_client_id
}
