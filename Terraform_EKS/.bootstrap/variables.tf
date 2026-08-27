variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Multi-Cloud-Kubernetes-Platform"
}

variable "aws_region" {
  description = "region for s3"
  type        = string
  default     = "eu-north-1"
}

variable "state_bucket_name" {
  description = "Full s3 name for .tfstate"
  type        = string
  default     = "allegro-analytics-eks-tfstate-2026"
}

variable "github_token" {
  description = "GitHub token with permissions to manage repository environments and secrets"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub owner (organization or user)"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name without owner"
  type        = string
}