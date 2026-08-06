output "eks_nodes_sg_id" {
  value = aws_security_group.eks_nodes.id
}

output "eks_cluster_sg_id" {
  value = aws_security_group.eks_cluster.id
}

output "endpoints_sg_id" {
  value = aws_security_group.vpc_endpoints.id
}

output "management_sg_id" {
  value = aws_security_group.management.id
}

output "cilium_enis_sg_id" {
  value = aws_security_group.cilium_enis.id
}