variable "project_name" {
  description = "Project name"
  type        = string
}


variable "resource_group_name" {
  description = "Resource group containing the Traffic Manager profile"
  type        = string
}


variable "aws_cloudfront_hostname" {
  description = "AWS CloudFront hostname."
  type        = string
  default     = "aws-placeholder.invalid"
}


variable "azure_frontdoor_hostname" {
  description = "Azure Front Door endpoint hostname"
  type        = string
}


variable "health_probe_path" {
  description = "Health probe path used by Traffic Manager"
  type        = string
  default     = "/api/health"
}

variable "common_tags" {
  description = "Tags applied to Traffic Manager resources"
  type        = map(string)
  default     = {}
}