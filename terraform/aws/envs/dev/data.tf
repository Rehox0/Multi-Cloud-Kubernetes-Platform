data "aws_secretsmanager_secret" "multi_cloud_project" {
  name = "multi-cloud-project-dev"
}

data "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain      = "app.multi-cloud-kubernetes.cloud"
  statuses    = ["ISSUED"]
  most_recent = true
}