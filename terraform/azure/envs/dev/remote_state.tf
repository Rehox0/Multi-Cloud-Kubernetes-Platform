data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = "multi-cloud-project-tfstate-2026"
    key    = "envs/dev/eks/terraform.tfstate"
    region = "eu-central-1"
  }
}