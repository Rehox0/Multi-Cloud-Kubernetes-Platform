output "nlb_arn" {
  description = "ARN of the Gateway internal NLB"
  value       = aws_lb.gateway.arn
}

output "nlb_dns_name" {
  description = "DNS name of the Gateway internal NLB"
  value       = aws_lb.gateway.dns_name
}

output "target_group_arn" {
  description = "ARN of the Gateway NLB target group"
  value       = aws_lb_target_group.gateway.arn
}
