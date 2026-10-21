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

variable "aliases" {
  description = "Custom domain names associated with CloudFront"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate used by CloudFront"
  type        = string
}
