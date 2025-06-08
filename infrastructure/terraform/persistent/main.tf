provider "aws" {
  region = "us-east-1"

  # Use profile only when available (local development)
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "persistent"
      ManagedBy   = "terraform"
    }
  }
}
