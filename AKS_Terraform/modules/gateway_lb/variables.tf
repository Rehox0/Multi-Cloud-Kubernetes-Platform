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

variable "gateway_node_port" {
  description = "NodePort exposed by the Cilium Gateway"
  type        = number
}

variable "gateway_frontend_port" {
  description = "Frontend port for the load balancer"
  type        = number
}

variable "protocol" {
  description = "Protocol for the load balancer (TCP/UDP)"
  type        = string
}
variable "aks_vmss_id" {
  description = "The ID of the AKS VMSS to which the load balancer backend pool will be associated"
  type        = string
}

variable "aks_vmss_name" {
  description = "The name of the AKS VMSS to which the load balancer backend pool will be associated"
  type        = string
}