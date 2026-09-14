variable "project_name" {
  description = "Project name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Front Door resources"
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

variable "private_link_subnet_id" {
  description = "Dedicated subnet for the Azure Private Link Service"
  type        = string
}

variable "gateway_lb_frontend_ip" {
  description = "Private frontend IP of the Terraform-managed AKS Gateway Load Balancer"
  type        = string
}

variable "gateway_lb_frontend_ip_configuration_id" {
  description = "Frontend IP configuration ID of the AKS Gateway Load Balancer"
  type        = string
}
