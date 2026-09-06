variable "project_name" {
  type = string
}

variable "cluster_name" {
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

variable "kubernetes_version" {
  type = string
}

variable "node_vm_size" {
  type = string
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_labels" {
  type    = map(string)
  default = {}
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID for the private AKS cluster"
}

variable "identity_id" {
  type        = string
  description = "User Assigned Identity ID used by AKS"
}
