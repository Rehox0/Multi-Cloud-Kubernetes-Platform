resource "aws_iam_openid_connect_provider" "eks" {
  url = var.eks_oidc_url

  client_id_list = ["sts.amazonaws.com"]

  tags = var.common_tags
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = var.gha_oidc_url

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint
  ]

  tags = var.common_tags
}