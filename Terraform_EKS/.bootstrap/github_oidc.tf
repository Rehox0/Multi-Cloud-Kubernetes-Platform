locals {
  github_repo_slug = "${var.github_owner}/${var.github_repository}"
  github_oidc_aud  = "sts.amazonaws.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = [local.github_oidc_aud]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "github_actions_dev" {
  name = "github-actions-terraform-ssm-role-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = local.github_oidc_aud
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${local.github_repo_slug}:environment:dev",
              "repo:${local.github_repo_slug}:ref:refs/heads/testing",
            ]
          }
        }
      },
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# resource "aws_iam_role" "github_actions_prod" {
#   name = "github-actions-terraform-ssm-role-prod"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.github.arn
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "token.actions.githubusercontent.com:aud" = local.github_oidc_aud
#           }
#           StringLike = {
#             "token.actions.githubusercontent.com:sub" = [
#               "repo:${local.github_repo_slug}:environment:prod",
#             ]
#           }
#         }
#       },
#     ]
#   })

#   tags = {
#     Project     = var.project_name
#     Environment = "prod"
#     ManagedBy   = "Terraform"
#   }
# }

resource "aws_iam_role_policy" "github_actions_dev_ssm_runner" {
  name = "github-actions-terraform-ssm-role-dev-ssm-runner"
  role = aws_iam_role.github_actions_dev.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManagementAsgLookup"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
        ]
        Resource = "*"
      },
      {
        Sid    = "ManagementInstanceLookup"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
        ]
        Resource = "*"
      },
      {
        Sid    = "RunTerraformViaSsm"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:CancelCommand",
        ]
        Resource = "*"
      },
    ]
  })
}

# resource "aws_iam_role_policy" "github_actions_prod_ssm_runner" {
#   name = "github-actions-terraform-ssm-role-prod-ssm-runner"
#   role = aws_iam_role.github_actions_prod.id

#   policy = aws_iam_role_policy.github_actions_dev_ssm_runner.policy
# }

resource "github_actions_environment_secret" "dev_role_arn" {
  repository      = var.github_repository
  environment     = "dev"
  secret_name     = "AWS_GITHUB_ACTIONS_ROLE_ARN"
  plaintext_value = aws_iam_role.github_actions_dev.arn
}

# resource "github_actions_environment_secret" "prod_role_arn" {
#   repository      = var.github_repository
#   environment     = "prod"
#   secret_name     = "AWS_GITHUB_ACTIONS_ROLE_ARN"
#   plaintext_value = aws_iam_role.github_actions_prod.arn
# }
