resource "aws_iam_role" "management_role" {
  name = "eks-management-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.management_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "management_terraform_backend" {
  name = "eks-management-terraform-backend-access"
  role = aws_iam_role.management_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = "arn:aws:s3:::allegro-analytics-eks-tfstate-2026"
      },
      {
        Sid    = "TerraformStateObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::allegro-analytics-eks-tfstate-2026/envs/*/eks/terraform.tfstate"
      },
      {
        Sid    = "TerraformStateLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
        ]
        Resource = "arn:aws:dynamodb:eu-north-1:*:table/terraform-state-lock"
      },
    ]
  })
}

resource "aws_iam_role_policy" "management_terraform_apply" {
  name = "eks-management-terraform-apply-access"
  role = aws_iam_role.management_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformApplyCoreServices"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "eks:Describe*",
          "eks:List*",
          "eks:AccessKubernetesApi",
          "eks:UpdateClusterConfig",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "iam:Get*",
          "iam:List*",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:GetResourcePolicy",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "management_profile" {
  name = "eks-management-profile"
  role = aws_iam_role.management_role.name

  tags = var.common_tags
}

resource "aws_eks_access_entry" "management_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.management_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "management_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.management_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.management_admin]
}

resource "aws_eks_access_entry" "console_user_admin" {
  count = var.eks_console_user_principal_arn != "" ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = var.eks_console_user_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "console_user_admin" {
  count = var.eks_console_user_principal_arn != "" ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = var.eks_console_user_principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.console_user_admin]
}

