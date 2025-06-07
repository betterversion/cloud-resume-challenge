locals {
  # Core suffix for all resources
  resource_suffix = "${var.project_name}-${terraform.workspace}"
  environment = terraform.workspace

  # Common tags for all resources
  common_tags = {
    Name        = "${local.resource_suffix}"
    Environment = title(local.environment)
    Project     = "CloudResume"
    ManagedBy   = "terraform"
    Workspace   = terraform.workspace
  }

  # API Gateway specific locals
  api_name = "${local.resource_suffix}-visitor-api"
  api_stage_name = "${local.resource_suffix}-api-stage"

  # Lambda function naming (if you want to centralize this too)
  lambda_function_name = "${local.resource_suffix}-visitor-counter"
  lambda_zip_path = "lambda_function_${terraform.workspace}.zip"
  lambda_log_group = "/aws/lambda/${local.lambda_function_name}"
}
