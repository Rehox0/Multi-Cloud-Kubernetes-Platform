resource "aws_iam_role" "cilium_operator" {
  name = "${var.project_name}-cilium-operator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cilium-operator"
        }
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "cilium_operator_policy" {
  name = "${var.project_name}-cilium-operator-policy"
  role = aws_iam_role.cilium_operator.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}
