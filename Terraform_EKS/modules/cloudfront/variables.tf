variable "project_name" {
  description = "Project name used for CloudFront resource naming"
  type        = string
}

variable "gateway_nlb_arn" {
  description = "ARN of the internal NLB used as the CloudFront VPC Origin"
  type        = string
}

variable "gateway_nlb_dns_name" {
  description = "DNS name of the internal NLB used as the CloudFront origin"
  type        = string
}
