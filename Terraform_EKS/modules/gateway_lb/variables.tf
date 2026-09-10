variable "project_name" {
  description = "Project name used for AWS resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the internal NLB will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the internal NLB"
  type        = list(string)
}

variable "gateway_node_port" {
  description = "NodePort exposed by the Cilium Gateway"
  type        = number
  default     = 31738
}

variable "gateway_name" {
  description = "Name used for AWS Gateway Load Balancer resources"
  type        = string
  default     = "terraform-gateway"
}

variable "gateway_nlb_sg_id" {
  description = "Security group ID for the Gateway NLB"
  type        = string
}