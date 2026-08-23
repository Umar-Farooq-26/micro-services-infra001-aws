terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # No hardcoded account ID here on purpose -- the original Azure providers.tf
  # had `subscription_id = "55e255f2-..."` committed in plaintext, which is a
  # real credential leak risk. Auth here instead comes from whatever's already
  # configured for the AWS CLI/SDK: environment variables (AWS_ACCESS_KEY_ID /
  # AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN), an `~/.aws/credentials`
  # profile, or (recommended, and what the CI workflow uses) an assumed IAM
  # role via GitHub OIDC.
}
