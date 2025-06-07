resource "aws_acm_certificate" "website" {
  domain_name               = "dzresume.dev"
  validation_method         = "DNS"
  subject_alternative_names = ["*.dzresume.dev"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "resume-site-cert"
  }
}
