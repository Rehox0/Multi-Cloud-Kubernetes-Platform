variable "project_name" {
  description = "Project name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Front Door resources"
  type        = string
}

variable "common_tags" {
  description = "Tags applied to Front Door resources"
  type        = map(string)
  default     = {}
}

variable "aks_node_resource_group" {
  type = string
}

# variable "application_gateway_id" {
#   description = "Application Gateway used as Azure Front Door origin"
#   type        = string
# }

variable "location" {
  description = "Azure region for Front Door Private Link"
  type        = string
}

# variable "application_gateway_public_ip" {
#   description = "Public IP address of Application Gateway"
#   type        = string
# }
