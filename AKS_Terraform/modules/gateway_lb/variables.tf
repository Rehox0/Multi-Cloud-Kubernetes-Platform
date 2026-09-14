variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the load balancer will be created"
  type        = string
}

variable "aks_subnet_id" {
  description = "The ID of the subnet where the load balancer will be deployed"
  type        = string
}

variable "common_tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
}