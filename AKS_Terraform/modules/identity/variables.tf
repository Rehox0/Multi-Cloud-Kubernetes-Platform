variable "project_name" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for managed identities"
}

variable "location" {
  type        = string
  description = "Azure region for managed identities"
}

variable "aks_private_dns_zone_id" {
  type        = string
  description = "ID of the AKS private DNS zone"
}

variable "backend_keyvault_id" {
  type        = string
  description = "ID of the backend Key Vault"
}
