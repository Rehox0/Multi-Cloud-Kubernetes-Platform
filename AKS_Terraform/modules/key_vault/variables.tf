variable "project_name" {
  type        = string
  description = "Project name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for Key Vault"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}