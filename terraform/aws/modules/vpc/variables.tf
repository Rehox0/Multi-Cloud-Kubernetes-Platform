variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR list for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR list for private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "azure_vpn_gateway_public_ip_1" {
  description = "Public IP of the first Azure VPN Gateway instance"
  type        = string
}

variable "azure_vpn_gateway_public_ip_2" {
  description = "Public IP of the second Azure VPN Gateway instance"
  type        = string
}

variable "azure_destination_cidr_block" {
  description = "CIDR block for the Azure PostgreSQL subnet to route traffic to"
  type        = string
}

variable "azure_aks_destination_cidr_block" {
  description = "CIDR of the Azure AKS VNet reachable through the site-to-site VPN"
  type        = string
}