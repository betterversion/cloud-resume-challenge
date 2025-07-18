terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

    backend "s3" {
    bucket         = "crc-terraform-state-prod"
    key            = "application/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  # Use profile only when available (local development)
  profile = var.aws_profile != "" ? var.aws_profile : null
  default_tags {
    tags = local.common_tags
  }
}
