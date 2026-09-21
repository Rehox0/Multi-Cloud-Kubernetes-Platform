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
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "admin_source_ip" {
  type        = string
}

variable "vm_size" {
  type    = string
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

variable "priority" { type = string }
variable "eviction_policy" { type = string }
variable "max_bid_price" { type = number }

variable "aks_node_resource_group_id" {
  description = "Resource ID of the AKS managed node resource group"
  type        = string
}

variable "aks_cluster_id" {
  description = "AKS cluster resource ID"
  type        = string
}