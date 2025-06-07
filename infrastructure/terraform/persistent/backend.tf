terraform {
  backend "s3" {
    bucket         = "crc-terraform-state-prod"
    key            = "persistent/default.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
