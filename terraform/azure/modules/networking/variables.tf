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

# variable "application_gateway_subnet_cidr" {
#   type        = string
#   description = "Dedicated subnet for Azure Application Gateway"
# }

# variable "application_gateway_private_link_subnet_cidr" {
#   type        = string
#   description = "Dedicated subnet for Application Gateway Private Link"
# }

variable "postgresql_subnet_cidr" {
  description = "CIDR range for the PostgreSQL Flexible Server delegated subnet"
  type        = string
}

variable "vpn_gateway_bgp_apipa_addresses" {
  description = "APIPA addresses used by the Azure VPN Gateway for BGP peering"
  type        = list(string)

  validation {
    condition     = length(var.vpn_gateway_bgp_apipa_addresses) == 4
    error_message = "Exactly two BGP APIPA addresses must be provided."
  }
}

variable "aws_vpn_tunnel_outside_ips" {
  description = "Public IP addresses of AWS VPN tunnel endpoints"
  type = object({
    vpn_1_tunnel_1 = string
    vpn_1_tunnel_2 = string
    vpn_2_tunnel_1 = string
    vpn_2_tunnel_2 = string
  })
}

variable "aws_vpn_tunnel_psks" {
  description = "Pre-shared keys for AWS VPN tunnels"
  type = object({
    vpn_1_tunnel_1 = string
    vpn_1_tunnel_2 = string
    vpn_2_tunnel_1 = string
    vpn_2_tunnel_2 = string
  })
  sensitive = true
}
