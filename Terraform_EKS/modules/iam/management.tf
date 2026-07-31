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

resource "aws_iam_policy" "ec2_modify_eni" {
  name        = "EC2ModifyNetworkInterfaceAttribute"
  description = "Allow to modify source_dest_check on ENI interfaces"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:ModifyNetworkInterfaceAttribute"
        ]
        Resource = "*"
      }
    ]
  })
}

