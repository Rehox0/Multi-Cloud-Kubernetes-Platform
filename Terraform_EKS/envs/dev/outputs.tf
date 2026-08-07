output "eks_nodes_sg_id" {
  value = module.security_groups.eks_nodes_sg_id
}

output "eks_cluster_sg_id" {
  value = module.security_groups.eks_cluster_sg_id
}

output "endpoints_sg_id" {
  value = module.security_groups.endpoints_sg_id
}

output "cilium_enis_sg_id" {
  value = module.security_groups.cilium_enis_sg_id
}