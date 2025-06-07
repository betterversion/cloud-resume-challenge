# output.tf - Comprehensive Persistent Layer Outputs
# Provides all necessary information for application layers and operations

# =============================================================================
# 🌍 ENVIRONMENT INFORMATION
# =============================================================================
output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Current AWS region"
  value       = data.aws_region.current.name
}

output "deployment_info" {
  description = "Deployment metadata for reference"
  value = {
    account_id        = data.aws_caller_identity.current.account_id
    region            = data.aws_region.current.name
    deployed_at       = timestamp()
    terraform_version = "Managed by Terraform"
  }
}

# =============================================================================
# 🌐 WEBSITE HOSTING (S3 + CloudFront)
# =============================================================================
output "website_bucket_name" {
  description = "S3 website bucket name for static content"
  value       = aws_s3_bucket.website.bucket
}

output "website_bucket_arn" {
  description = "S3 website bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "website_bucket_domain_name" {
  description = "S3 website bucket domain name"
  value       = aws_s3_bucket.website.bucket_domain_name
}

output "website_bucket_regional_domain_name" {
  description = "S3 website bucket regional domain name"
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "logs_bucket_name" {
  description = "S3 logs bucket name for CloudFront access logs"
  value       = aws_s3_bucket.cloudfront_logs.bucket
}

output "logs_bucket_arn" {
  description = "S3 logs bucket ARN"
  value       = aws_s3_bucket.cloudfront_logs.arn
}

# =============================================================================
# ☁️ CLOUDFRONT CDN - Main Distribution (Production)
# =============================================================================
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache management"
  value       = aws_cloudfront_distribution.website.id
}

output "cf_main_distribution_id" {
  description = "Main CloudFront distribution ID (for scripts)"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (primary access point)"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.website.arn
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID (for Route53 aliases)"
  value       = aws_cloudfront_distribution.website.hosted_zone_id
}

output "cloudfront_status" {
  description = "CloudFront distribution deployment status"
  value       = aws_cloudfront_distribution.website.status
}

output "website_url" {
  description = "Primary website URL via CloudFront"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

# =============================================================================
# ☁️ CLOUDFRONT CDN - Test Distribution (Staging)
# =============================================================================
output "cf_test_distribution_id" {
  description = "Test CloudFront distribution ID (for scripts)"
  value       = aws_cloudfront_distribution.website_test.id
}

output "test_website_url" {
  description = "Test website URL via CloudFront"
  value       = "https://${aws_cloudfront_distribution.website_test.domain_name}"
}

# =============================================================================
# 🔄 ENVIRONMENT STATE
# =============================================================================
output "active_environment" {
  description = "Currently active environment (blue/green)"
  value       = var.active_environment
}

# =============================================================================
# 🔒 SSL/TLS CERTIFICATES (ACM)
# =============================================================================
output "consolidated_cert_arn" {
  description = "ACM certificate ARN for dzresume.dev and *.dzresume.dev"
  value       = aws_acm_certificate.website.arn
}

output "consolidated_cert_domain_name" {
  description = "Primary domain name on the certificate"
  value       = aws_acm_certificate.website.domain_name
}

output "consolidated_cert_subject_alternative_names" {
  description = "Subject Alternative Names (SANs) on the certificate"
  value       = aws_acm_certificate.website.subject_alternative_names
}

output "consolidated_cert_status" {
  description = "Certificate validation status"
  value       = aws_acm_certificate.website.status
}

output "consolidated_cert_validation" {
  description = "DNS validation records required for certificate validation"
  value       = aws_acm_certificate.website.domain_validation_options
  sensitive   = false
}

# =============================================================================
# 🔐 IAM ROLES & POLICIES
# =============================================================================
output "lambda_execution_role_arn" {
  description = "IAM role ARN for Lambda function execution"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "IAM role name for Lambda function execution"
  value       = aws_iam_role.lambda_execution_role.name
}

output "lambda_execution_role_id" {
  description = "IAM role unique ID"
  value       = aws_iam_role.lambda_execution_role.unique_id
}

output "lambda_role_policy_info" {
  description = "Lambda IAM role policy information"
  value = {
    role_arn            = aws_iam_role.lambda_execution_role.arn
    role_name           = aws_iam_role.lambda_execution_role.name
    has_dynamodb_access = "Includes DynamoDB read/write permissions"
    has_cloudwatch_logs = "Includes CloudWatch Logs permissions"
  }
}

# =============================================================================
# 🗄️ DATABASE (DynamoDB)
# =============================================================================
output "dynamodb_table_name" {
  description = "DynamoDB visitor counter table name"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB visitor counter table ARN"
  value       = aws_dynamodb_table.visitor_counter.arn
}

output "dynamodb_table_id" {
  description = "DynamoDB visitor counter table ID"
  value       = aws_dynamodb_table.visitor_counter.id
}

output "dynamodb_table_hash_key" {
  description = "DynamoDB table hash key attribute name"
  value       = aws_dynamodb_table.visitor_counter.hash_key
}

output "dynamodb_table_billing_mode" {
  description = "DynamoDB table billing mode"
  value       = aws_dynamodb_table.visitor_counter.billing_mode
}

output "dynamodb_table_point_in_time_recovery" {
  description = "DynamoDB Point-in-Time Recovery status"
  value       = aws_dynamodb_table.visitor_counter.point_in_time_recovery[0].enabled
}

output "dynamodb_table_info" {
  description = "Complete DynamoDB table information"
  value = {
    table_name   = aws_dynamodb_table.visitor_counter.name
    table_arn    = aws_dynamodb_table.visitor_counter.arn
    hash_key     = aws_dynamodb_table.visitor_counter.hash_key
    billing_mode = aws_dynamodb_table.visitor_counter.billing_mode
    table_class  = aws_dynamodb_table.visitor_counter.table_class
    pitr_enabled = aws_dynamodb_table.visitor_counter.point_in_time_recovery[0].enabled
  }
}

# =============================================================================
# 🛠️ OPERATIONAL COMMANDS
# =============================================================================
output "cache_invalidation_command" {
  description = "AWS CLI command to invalidate CloudFront cache"
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.website.id} --paths '/*'"
}

output "website_sync_command" {
  description = "AWS CLI command to sync Hugo site to S3 with environment path"
  value       = "aws s3 sync ./frontend/hugo/public/ s3://${aws_s3_bucket.website.bucket}/$${ENVIRONMENT}/ --delete"
}

output "website_sync_blue_command" {
  description = "AWS CLI command to sync Hugo site to S3 blue environment"
  value       = "aws s3 sync ./frontend/hugo/public/ s3://${aws_s3_bucket.website.bucket}/blue/ --delete"
}

output "website_sync_green_command" {
  description = "AWS CLI command to sync Hugo site to S3 green environment"
  value       = "aws s3 sync ./frontend/hugo/public/ s3://${aws_s3_bucket.website.bucket}/green/ --delete"
}

output "logs_download_command" {
  description = "AWS CLI command to download CloudFront access logs"
  value       = "aws s3 sync s3://${aws_s3_bucket.cloudfront_logs.bucket}/ ./logs/"
}

output "dynamodb_scan_command" {
  description = "AWS CLI command to scan DynamoDB table"
  value       = "aws dynamodb scan --table-name ${aws_dynamodb_table.visitor_counter.name}"
}

output "s3_list_environments_command" {
  description = "AWS CLI command to list environment folders in S3"
  value       = "aws s3 ls s3://${aws_s3_bucket.website.bucket}/ --recursive --human-readable"
}

# =============================================================================
# 🔗 USEFUL URLS & LINKS
# =============================================================================
output "aws_console_links" {
  description = "Direct links to AWS Console resources"
  value = {
    s3_website_bucket  = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.website.bucket}"
    s3_logs_bucket     = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.cloudfront_logs.bucket}"
    cloudfront_console = "https://console.aws.amazon.com/cloudfront/v3/home?region=${data.aws_region.current.name}#/distributions/${aws_cloudfront_distribution.website.id}"
    dynamodb_console   = "https://console.aws.amazon.com/dynamodbv2/home?region=${data.aws_region.current.name}#table?name=${aws_dynamodb_table.visitor_counter.name}"
    iam_role_console   = "https://console.aws.amazon.com/iam/home#/roles/${aws_iam_role.lambda_execution_role.name}"
    acm_certificate    = "https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates/${replace(aws_acm_certificate.website.arn, "/.*\\//", "")}"
  }
}
