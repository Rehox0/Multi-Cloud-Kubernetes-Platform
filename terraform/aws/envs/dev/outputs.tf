output "eks_nodes_sg_id" {
  value = module.security_groups.eks_nodes_sg_id
}

output "eks_cluster_sg_id" {
  value = module.security_groups.eks_cluster_sg_id
}

output "eks_oidc_url" {
  description = "OIDC issuer URL of the EKS cluster"
  value       = module.eks.eks_oidc_url
}

output "endpoints_sg_id" {
  value = module.security_groups.endpoints_sg_id
}

output "azure_vpn_1_tunnel1_psk" {
  value     = module.vpc.azure_vpn_1_tunnel1_psk
  sensitive = true
}

output "azure_vpn_1_tunnel2_psk" {
  value     = module.vpc.azure_vpn_1_tunnel2_psk
  sensitive = true
}

output "azure_vpn_2_tunnel1_psk" {
  value     = module.vpc.azure_vpn_2_tunnel1_psk
  sensitive = true
}

output "azure_vpn_2_tunnel2_psk" {
  value     = module.vpc.azure_vpn_2_tunnel2_psk
  sensitive = true
}

output "azure_vpn_1_tunnel1_outside_ip" {
  value = module.vpc.azure_vpn_1_tunnel1_outside_ip
}

output "azure_vpn_1_tunnel2_outside_ip" {
  value = module.vpc.azure_vpn_1_tunnel2_outside_ip
}

output "azure_vpn_2_tunnel1_outside_ip" {
  value = module.vpc.azure_vpn_2_tunnel1_outside_ip
}

output "azure_vpn_2_tunnel2_outside_ip" {
  value = module.vpc.azure_vpn_2_tunnel2_outside_ip
}
