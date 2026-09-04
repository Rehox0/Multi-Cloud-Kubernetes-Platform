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

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "admin_source_ip" {
  description = "Public IP address allowed to SSH into the jumpbox"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s_v2"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "kubectl_version" { type = string }
variable "kubectl_sha256" { type = string }
variable "kubelogin_version" { type = string }
variable "kubelogin_sha256" { type = string }
variable "helm_version" { type = string }
variable "helm_sha256" { type = string }
