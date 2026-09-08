variable "project_name" {
  type        = string
  description = "Project name"
}

variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
  default     = {}
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

variable "private_link_subnet_cidr" {
  description = "CIDR range dedicated to Azure Private Link Service"
  type        = string
}


variable "jumpbox_network" {
  description = "Network configuration for the Jumpbox VNet"

  type = object({
    location    = string
    vnet_cidr   = string
    subnet_cidr = string
  })
}
