module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]

  cluster_name = local.cluster_name
  common_tags  = local.tags
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  cluster_name = local.cluster_name

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.node_role_arn

  subnet_ids = module.vpc.private_subnets

  eks_nodes_sg_id      = module.security_groups.eks_nodes_sg_id
  eks_cluster_sg_id    = module.security_groups.eks_cluster_sg_id
  node_instance_types  = ["t3.medium"]
  node_desired_size    = 3
  node_min_size        = 2
  node_max_size        = 6
  node_max_unavailable = 1
  node_labels = {
    env = "prod"
  }
  cluster_version = var.cluster_version

  common_tags = local.tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  common_tags             = local.tags
  alb_ingress_cidr_blocks = var.alb_ingress_cidr_blocks
}

module "vpc_endpoints" {
  source = "../../modules/vpc_endpoints"

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnets
  private_route_table_ids = module.vpc.private_route_table_ids
  endpoints_sg_id         = module.security_groups.endpoints_sg_id
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  cluster_name = module.eks.cluster_name
  eks_oidc_url = module.eks.eks_oidc_url
  secret_arn   = data.aws_secretsmanager_secret.manual_secrets.arn

  common_tags = local.tags
}

module "helm_charts" {
  source = "../../helm"

  aws_region                   = var.aws_region
  vpc_id                       = module.vpc.vpc_id
  cluster_name                 = module.eks.cluster_name
  cluster_endpoint             = module.eks.cluster_endpoint
  cluster_ca_certificate       = module.eks.cluster_certificate_authority_data
  alb_controller_role_arn      = module.iam.alb_controller_role_arn
  cilium_role_arn              = module.iam.cilium_operator_role_arn
  eks_nodes_sg_id              = module.eks.node_security_group_id
  alb_controller_chart_version = var.alb_controller_chart_version
  cilium_chart_version         = var.cilium_chart_version

  depends_on = [module.eks]
}

module "management" {
  source = "../../modules/management"

  subnet_ids            = module.vpc.private_subnets
  instance_profile_name = module.iam.management_instance_profile_name
  management_sg_id      = module.security_groups.management_sg_id
  aws_region            = var.aws_region
  cluster_name          = module.eks.cluster_name
  kubectl_version       = var.kubectl_version
  kubectl_sha256        = var.kubectl_sha256
  helm_version          = var.helm_version
  helm_sha256           = var.helm_sha256
  terraform_version     = var.terraform_version
  terraform_sha256      = var.terraform_sha256
  ssh_public_keys       = var.management_ssh_public_keys
}
