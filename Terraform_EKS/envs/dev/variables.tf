variable "project_name" {
  description = "Name for the project"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  description = "Standard tags for all assets in the project"
  default = {
    Project     = "allegro-analytics-eks"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "secrets_name" {
  type    = string
  default = "allegro-app-secrets-dev"
}

variable "alb_ingress_cidr_blocks" {
  type        = list(string)
  description = "Allowed CIDR ranges for the private ALB"
}

variable "cluster_version" {
  type        = string
  description = "EKS control plane version"
  default     = "1.35"
}

variable "kubectl_version" {
  type        = string
  description = "Pinned kubectl version installed on the management host"
  default     = "v1.35.1"
}

variable "kubectl_sha256" {
  type        = string
  description = "SHA256 checksum for the pinned kubectl binary"
  default     = "36e2f4ac66259232341dd7866952d64a958846470f6a9a6a813b9117bd965207"
}

variable "helm_version" {
  type        = string
  description = "Pinned Helm version installed on the management host"
  default     = "v3.19.4"
}

variable "helm_sha256" {
  type        = string
  description = "SHA256 checksum for the pinned Helm archive"
  default     = "759c656fbd9c11e6a47784ecbeac6ad1eb16a9e76d202e51163ab78504848862"
}

variable "management_ssh_public_keys" {
  type        = list(string)
  description = "Public SSH keys injected into management host authorized_keys"
}

variable "eks_console_user_principal_arn" {
  type        = string
  description = "IAM principal ARN (IAM User) to receive EKS cluster admin access entry"
  default     = ""
}

variable "alb_controller_chart_version" {
  type        = string
  description = "Pinned chart version for aws-load-balancer-controller"
  default     = "1.15.0"
}

variable "cilium_chart_version" {
  type        = string
  description = "Pinned chart version for cilium"
  default     = "1.18.4"
}
