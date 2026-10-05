#State s3 + dynamodb
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table name for state locking"
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

#ECR Backend
output "aws_ecr_repository_url_backend" {
  value = aws_ecr_repository.backend.repository_url
}

#ECR Frontend
output "aws_ecr_repository_url_frontend" {
  value = aws_ecr_repository.frontend.repository_url
}

#Secrets Dev
output "secrets_manager_arn_dev" {
  value = aws_secretsmanager_secret.secrets_dev.arn
}

#Secrets Prod
# output "secrets_manager_arn_prod" {
#   value = aws_secretsmanager_secret.secrets_prod.arn
# }

#GHA Roles
output "github_actions_role_arn_dev" {
  value       = aws_iam_role.github_actions_dev.arn
  description = "IAM role ARN used by GitHub Actions for the dev environment"
}

# output "github_actions_role_arn_prod" {
#   value       = aws_iam_role.github_actions_prod.arn
#   description = "IAM role ARN used by GitHub Actions for the prod environment"
# }

output "github_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "ARN of the GitHub OIDC provider in AWS IAM"
}
