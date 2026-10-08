output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "vpc_origin_id" {
  description = "CloudFront VPC Origin ID"
  value       = aws_cloudfront_vpc_origin.gateway.id
}