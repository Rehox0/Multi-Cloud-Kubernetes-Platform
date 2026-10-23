locals {
  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  cluster_name = "${var.project_name}-aks-cluster"
}