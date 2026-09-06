variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
  default     = {}
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  description = "Name of the resource group where VNet will be created"
  type        = string
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR range for Virtual Network"
}

variable "aks_subnet_cidrs" {
  type        = list(string)
  description = "CIDR list for AKS subnets"
}

variable "jumpbox_network" {
  description = "Network configuration for the Jumpbox VNet"

  type = object({
    location    = string
    vnet_cidr   = string
    subnet_cidr = string
  })
}
