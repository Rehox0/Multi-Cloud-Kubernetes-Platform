variable "common_tags" {
  description = "Tags passed from the environment"
  type        = map(string)
}

variable "project_name" { type = string }

variable "vpc_id" {
  type        = string
  description = "VPC ID from the network module"
}

variable "pod_security_group_id" {
  description = "Primary Security Group ID from EKS cluster used for Pod traffic"
  type        = string
}

variable "gateway_node_port" {
  description = "NodePort exposed by the Cilium Gateway"
  type        = number
  default     = 31738
}