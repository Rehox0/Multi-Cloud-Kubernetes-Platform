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

variable "grafana_admin_user" {
  type        = string
  description = "Grafana admin user"
}

variable "user_keyvault_secrets_officer_role_assignment_id" {
  description = "Role assignment that grants user permission to write Key Vault secrets"
  type        = string
}
