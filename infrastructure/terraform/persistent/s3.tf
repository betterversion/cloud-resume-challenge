# CloudFront access logs bucket - simple configuration
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "dzresume-logs-prod"

  tags = {
    Name    = "dzresume-logs-prod"
    Purpose = "CloudFront access logs"
  }
}

# Block all public access for logs bucket
resource "aws_s3_bucket_public_access_block" "cloudfront_logs_pab" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Main website content bucket
resource "aws_s3_bucket" "website" {
  bucket = "dzresume-prod"

  tags = {
    Name    = "dzresume-prod"
    Purpose = "Website content for blue-green deployment"
  }
}

# Block public access (CloudFront provides access)
resource "aws_s3_bucket_public_access_block" "website_pab" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = [
              aws_cloudfront_distribution.website.arn,
              aws_cloudfront_distribution.website_test.arn
            ]
          }
        }
      }
    ]
  })
}
