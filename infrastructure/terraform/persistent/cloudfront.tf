# Calculate the inactive environment automatically
locals {
  # When active is "blue", inactive becomes "green" and vice versa
  inactive_environment = var.active_environment == "blue" ? "green" : "blue"
}


resource "aws_cloudfront_distribution" "website" {
  aliases             = ["dzresume.dev", "www.dzresume.dev"]
  comment             = "Resume site distribution"
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-dzresume-prod" # ← Fixed to match new bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id

    origin_path = "/${var.active_environment}" # ← 🔥 Key to blue-green magic

    connection_attempts = 3
    connection_timeout  = 10
  }

  default_cache_behavior {
    target_origin_id       = "S3-dzresume-prod" # ← Fixed to match origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "dzresume-cloudfront-prod" # ← Updated tag for clarity
  }
}

resource "aws_cloudfront_distribution" "website_test" {
  aliases             = ["test.dzresume.dev"]
  comment             = "Resume site TEST distribution"
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-dzresume-test"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
    origin_path              = "/${local.inactive_environment}"
    connection_attempts      = 3
    connection_timeout       = 10
  }

  default_cache_behavior {
    target_origin_id       = "S3-dzresume-test"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = { Name = "dzresume-cloudfront-test" }
}

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "dzresume-frontend-access-control"
  description                       = "OAC for frontend S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
