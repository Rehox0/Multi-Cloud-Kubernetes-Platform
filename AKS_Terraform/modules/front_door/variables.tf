variable "project_name" {
  description = "Project name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Front Door resources"
  type        = string
}

variable "aks_node_resource_group" {
  description = "AKS managed resource group containing the Cilium-created Load Balancer"
  type        = string
}

variable "private_link_location" {
  description = "Azure region used by Azure Front Door for the Private Link connection"
  type        = string
  default     = "germanywestcentral"
}

variable "common_tags" {
  description = "Tags applied to Front Door resources"
  type        = map(string)
  default     = {}
}

variable "aks_subnet_id" {
  description = "AKS subnet containing the Cilium Gateway Load Balancer frontend"
  type        = string
}

variable "private_link_subnet_id" {
  description = "Dedicated subnet for the Azure Private Link Service"
  type        = string
}

