variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Multi-Cloud-Kubernetes-Platform"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "polandcentral"
}

variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
  default     = {}
}

variable "cluster_version" {
  type        = string
  description = "EKS control plane version"
  default     = "1.35"
}
