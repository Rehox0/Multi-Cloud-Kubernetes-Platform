variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs from the VPC module"
}

variable "cluster_role_arn" {
  type        = string
  description = "ARN for IAM for an EKS cluster"
}

variable "eks_nodes_sg_id" {
  type        = string
  description = "ID Security Groups for nodes, provided by the security_groups module"
}

variable "eks_cluster_sg_id" {
  type        = string
  description = "ID Security Groups for cluster, provided by the security_groups module"
}

variable "node_role_arn" {
  type        = string
  description = "ARN of the IAM role for worker nodes provided by the IAM module"
}

variable "node_capacity_type" {
  type    = string
  default = "SPOT"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_max_unavailable" {
  type    = number
  default = 1
}

variable "node_labels" {
  type        = map(string)
  default     = {}
  description = "Additional labels for EKS nodes"
}

variable "cluster_version" {
  type        = string
  description = "EKS control plane version"
  default     = "1.35"
}

variable "cluster_addons" {
  type        = map(any)
  description = "Map of EKS cluster addons to install. Each key is the addon name, and the value is an object with the following attributes:"
  default = {
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
    coredns = {
      most_recent    = true
      before_compute = true
    }
  }
}

variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
