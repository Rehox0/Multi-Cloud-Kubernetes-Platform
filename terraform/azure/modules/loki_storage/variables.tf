variable "resource_group_name" {
  description = "Resource group for Loki storage"
  type        = string
}

variable "location" {
  description = "Azure region for Loki storage"
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name for Loki"
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace used by Loki"
  type        = string
  default     = "loki"
}

variable "kubernetes_service_account" {
  description = "Kubernetes ServiceAccount used by Loki"
  type        = string
  default     = "loki"
}

variable "loki_identity_id" {
  description = "Resource ID of the persistent Loki managed identity"
  type        = string
}

variable "loki_identity_principal_id" {
  description = "Principal ID of the persistent Loki managed identity"
  type        = string
}
