# Automatic Lambda code packaging using archive data source
# Creates workspace-specific zip files to avoid conflicts
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../../../backend/lambda/visitor-counter"
  output_path = local.lambda_zip_path
  excludes    = ["README.md", "*.md"]
}

# Lambda function for visitor counter with blue-green support
resource "aws_lambda_function" "visitor_counter" {
  # Workspace-aware function naming
  function_name = local.lambda_function_name

  # Use persistent layer role
  role          = data.terraform_remote_state.persistent.outputs.lambda_execution_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  timeout     = 3
  memory_size = 128
  description = "Visitor counter for ${local.environment} environment"
  publish     = true

  architectures = ["x86_64"]
  package_type  = "Zip"

  # Automatic code packaging - updates when source files change
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(local.common_tags, {
    Name = local.lambda_function_name
    Component = "lambda"
  })

  # Lifecycle management for blue-green deployments
  lifecycle {
    create_before_destroy = true
  }
}
