output "eks_oidc_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "pod_security_group_id" {
  description = "ID of the main security group created by EKS"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS Cluster Name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS Server API Endpoint"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Cluster CA data"
}

output "node_security_group_id" {
  value       = var.eks_nodes_sg_id
  description = "ID Security Groups for EKS nodes"
}