# Empty Security Group for Gateway NLB
resource "aws_security_group" "gateway_nlb" {
  name        = "${var.project_name}-gateway-nlb-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-gateway-nlb-sg"
  }
}

# Empty Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  name   = "${var.project_name}-eks-nodes-sg"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-eks-nodes-sg"
  })
}

# Empty Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name   = "${var.project_name}-eks-cluster-sg"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-eks-cluster-sg"
  })
}

# Empty Security Group for RDS PostgreSQL
resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-rds-sg"
  })
}

# Empty Security Group for ElastiCache
resource "aws_security_group" "valkey" {
  name   = "${var.project_name}-valkey-sg"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-valkey-sg"
  })
}

# Empty Security Group for VPC-Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name   = "${var.project_name}-vpc-endpoints-sg"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc-endpoints-sg"
  })
}

# Empty Security Group for Management
resource "aws_security_group" "management" {
  name   = "management-sg"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-management-sg"
  })
}