variable "project_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "postgresql_admin_login" {
  type = string
}

variable "key_vault_id" {
  description = "ID of the Azure Key Vault used to store the PostgreSQL administrator password"
  type        = string
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "postgresql_port" {
  type = string
  default = 5432
}

variable "postgresql_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  type = string
}