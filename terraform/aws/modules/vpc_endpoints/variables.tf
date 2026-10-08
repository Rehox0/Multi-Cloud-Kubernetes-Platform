variable "vpc_id" {
  type        = string
  description = "VPC ID where endpoints are created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for interface endpoints"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "Private route table IDs for gateway endpoints"
}

variable "endpoints_sg_id" {
  type        = string
  description = "Security group ID attached to interface endpoints"
}
