terraform {
  backend "s3" {
    bucket  = "multi-cloud-project-tfstate-2026"
    key     = "envs/dev/eks/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true

    dynamodb_table = "terraform-state-lock"
  }
}