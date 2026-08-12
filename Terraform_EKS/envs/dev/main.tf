
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]

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
  node_instance_types  = ["t3.small"]
  node_desired_size    = 6
  node_min_size        = 3
  node_max_size        = 9
  node_max_unavailable = 2
  node_labels = {
    env = "dev"
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
  pod_security_group_id   = module.eks.pod_security_group_id
}

module "vpc_endpoints" {
  source = "../../modules/vpc_endpoints"

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnets
  private_route_table_ids = module.vpc.private_route_table_ids
  endpoints_sg_id         = module.security_groups.endpoints_sg_id
}

module "iam" {
  source                         = "../../modules/iam"
  project_name                   = var.project_name
  cluster_name                   = module.eks.cluster_name
  eks_oidc_url                   = module.eks.eks_oidc_url
  secret_arn                     = data.aws_secretsmanager_secret.infra_project.arn
  eks_console_user_principal_arn = var.eks_console_user_principal_arn

  common_tags = local.tags
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
  ssh_public_keys       = var.management_ssh_public_keys

  depends_on = [
    module.eks
  ]
}
