variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Multi-Cloud-Project"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "polandcentral"
}

variable "storage_container_name" {
  description = "Name of the Azure Storage Container to hold .tfstate"
  type        = string
  default     = "multicloudprojecttfstate2026"
}

variable "state_storage_account_name" {
  description = "Base name for the Azure Storage Account holding .tfstate"
  type        = string
  default     = "sttfstate2026aks"
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