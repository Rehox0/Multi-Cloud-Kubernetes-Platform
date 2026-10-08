output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "alb_controller_role_arn" {
  value       = aws_iam_role.alb_controller.arn
  description = "ARN of the IAM role for the AWS Load Balancer Controller"
}

output "cilium_operator_role_arn" {
  value       = aws_iam_role.cilium_operator.arn
  description = "ARN for IAM in Cilium"
}

output "management_instance_profile_name" {
  value = aws_iam_instance_profile.management_profile.name
}

output "management_role_arn" {
  value       = aws_iam_role.management_role.arn
  description = "ARN of the management EC2 role used for Terraform operations"
}

output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_role_name" {
  value = aws_iam_role.karpenter_node.name
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}
