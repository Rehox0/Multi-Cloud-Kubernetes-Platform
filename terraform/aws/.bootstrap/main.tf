########## Create S3 ##########
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
  
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

########## DynamoDB ##########
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST" # Pay-as-you-go
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # String
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Project     = var.project_name
  }
}

########## Secrets Manager for Dev & Prod ##########
# NOTE: You need to pass secrets manually

resource "aws_secretsmanager_secret" "secrets_dev" {
  name = "multi-cloud-project-dev"
  tags = { Environment = "dev", Project = var.project_name }
}

# resource "aws_secretsmanager_secret" "secrets_prod" {
#   name = "allegro-app-secrets-prod"
#   tags = { Environment = "prod", Project = var.project_name }
# }

########## Create ECR ##########
resource "aws_ecr_repository" "frontend" {
  name                 = "multi-cloud-project-ecr-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Project = var.project_name }
}

resource "aws_ecr_repository" "backend" {
  name                 = "multi-cloud-project-ecr-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Project = var.project_name }
}