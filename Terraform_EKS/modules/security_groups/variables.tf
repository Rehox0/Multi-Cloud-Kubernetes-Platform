variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
}

variable "project_name" { type = string }

variable "vpc_id" {
  type        = string
  description = "VPC ID from the network module"
}

variable "alb_ingress_cidr_blocks" {
  type        = list(string)
  description = "IP ranges that can connect to the ALB"
}
