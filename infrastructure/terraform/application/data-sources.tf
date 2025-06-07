# AWS Region Information
data "aws_region" "current" {}

# AWS Account Information
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "persistent" {
  backend = "s3"

  config = {
    bucket               = "crc-terraform-state-prod"
    key                  = "persistent/default.tfstate"
    region               = "us-east-1"
    use_lockfile         = true                            
    encrypt              = true
  }
}
