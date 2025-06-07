# output.tf - Enhanced Blue-Green Application Layer Outputs

# =============================================================================
# 🔧 LAMBDA FUNCTION OUTPUTS
# =============================================================================
output "lambda_function_name" {
  description = "Name of the visitor-counter Lambda function for this workspace"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "lambda_function_arn" {
  description = "ARN of the visitor-counter Lambda function for this workspace"
  value       = aws_lambda_function.visitor_counter.arn
}

output "lambda_function_version" {
  description = "Version of the Lambda function (for blue-green tracking)"
  value       = aws_lambda_function.visitor_counter.version
}

output "lambda_info" {
  description = "Complete Lambda function information"
  value = {
    function_name    = aws_lambda_function.visitor_counter.function_name
    function_arn     = aws_lambda_function.visitor_counter.arn
    version          = aws_lambda_function.visitor_counter.version
    runtime          = aws_lambda_function.visitor_counter.runtime
    timeout          = aws_lambda_function.visitor_counter.timeout
    memory_size      = aws_lambda_function.visitor_counter.memory_size
    handler          = aws_lambda_function.visitor_counter.handler
    last_modified    = aws_lambda_function.visitor_counter.last_modified
    source_code_size = aws_lambda_function.visitor_counter.source_code_size
    environment      = terraform.workspace
  }
}

# =============================================================================
# 🌐 API GATEWAY OUTPUTS
# =============================================================================
output "api_gateway_name" {
  description = "API Gateway name for visitor counter in this workspace"
  value       = aws_api_gateway_rest_api.visitor_api.name
}

output "api_gateway_id" {
  description = "API Gateway REST API ID for this workspace"
  value       = aws_api_gateway_rest_api.visitor_api.id
}

output "api_stage_name" {
  description = "API Gateway stage name (matches workspace)"
  value       = aws_api_gateway_stage.api_stage.stage_name
}

output "api_gateway_info" {
  description = "Complete API Gateway information"
  value = {
    api_name           = aws_api_gateway_rest_api.visitor_api.name
    api_id             = aws_api_gateway_rest_api.visitor_api.id
    stage_name         = aws_api_gateway_stage.api_stage.stage_name
    deployment_id      = aws_api_gateway_deployment.api_deployment.id
    execution_arn      = aws_api_gateway_rest_api.visitor_api.execution_arn
    created_date       = aws_api_gateway_rest_api.visitor_api.created_date
    endpoint_type      = "REGIONAL"
    environment        = terraform.workspace
  }
}

# =============================================================================
# 🌐 API ENDPOINT URLS
# =============================================================================
output "api_gateway_url" {
  description = "Complete base URL for the visitor counter API in this workspace"
  value       = "https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
}

output "counter_endpoint_url" {
  description = "Complete URL for the visitor counter endpoint"
  value       = "https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/counter"
}

output "health_endpoint_url" {
  description = "Complete URL for the health check endpoint"
  value       = "https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/health"
}

output "api_endpoints" {
  description = "All API endpoints for this environment"
  value = {
    base_url     = "https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
    counter_url  = "https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/counter"
    health_url   = "https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/health"
    environment  = terraform.workspace
    region       = data.aws_region.current.name
  }
}

# =============================================================================
# 📊 MONITORING OUTPUTS
# =============================================================================
output "dashboard_url" {
  description = "CloudWatch Dashboard URL for this environment"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.application_dashboard.dashboard_name}"
}

output "dashboard_name" {
  description = "CloudWatch Dashboard name for this environment"
  value       = aws_cloudwatch_dashboard.application_dashboard.dashboard_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for deployment alerts in this environment"
  value       = aws_sns_topic.deployment_alerts.arn
}

output "lambda_log_group_name" {
  description = "CloudWatch Log Group name for Lambda function"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "api_log_group_name" {
  description = "CloudWatch Log Group name for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway_logs.name
}

output "monitoring_info" {
  description = "Complete monitoring and observability information"
  value = {
    dashboard_name         = aws_cloudwatch_dashboard.application_dashboard.dashboard_name
    dashboard_url         = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.application_dashboard.dashboard_name}"
    sns_topic_arn         = aws_sns_topic.deployment_alerts.arn
    lambda_log_group      = aws_cloudwatch_log_group.lambda_logs.name
    api_log_group         = aws_cloudwatch_log_group.api_gateway_logs.name
    lambda_logs_url       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.lambda_logs.name, "/", "$252F")}"
    api_logs_url          = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.api_gateway_logs.name, "/", "$252F")}"
    alarm_count           = "5 alarms configured"
    environment           = terraform.workspace
  }
}

# =============================================================================
# 🌍 ENVIRONMENT INFORMATION
# =============================================================================
output "environment" {
  description = "Current workspace environment (blue or green)"
  value       = terraform.workspace
}

output "resource_suffix" {
  description = "Resource naming suffix for this environment"
  value       = local.resource_suffix
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.name
}

output "environment_info" {
  description = "Complete environment information"
  value = {
    environment     = terraform.workspace
    aws_region     = data.aws_region.current.name
    resource_suffix = local.resource_suffix
    deployment_type = "blue-green"
    layer_type     = "application"
    resource_count = "33 resources deployed"
  }
}

# =============================================================================
# 🛠️ OPERATIONAL COMMANDS
# =============================================================================
output "test_commands" {
  description = "Ready-to-use commands for testing this environment"
  value = {
    test_health       = "curl -s https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/health"
    test_counter      = "curl -s https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/counter"
    test_with_format  = "curl -s https://${aws_api_gateway_rest_api.visitor_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/counter | jq '.'"
    invoke_lambda     = "aws lambda invoke --function-name ${aws_lambda_function.visitor_counter.function_name} response.json"
    view_lambda_logs  = "aws logs tail ${aws_cloudwatch_log_group.lambda_logs.name} --follow"
    view_api_logs     = "aws logs tail ${aws_cloudwatch_log_group.api_gateway_logs.name} --follow"
    list_alarms       = "aws cloudwatch describe-alarms --alarm-name-prefix ${local.resource_suffix}"
  }
}

output "deployment_commands" {
  description = "Commands for deployment management"
  value = {
    redeploy_api      = "terraform apply -target=aws_api_gateway_deployment.api_deployment"
    update_lambda     = "terraform apply -target=aws_lambda_function.visitor_counter"
    switch_workspace  = "terraform workspace select ${terraform.workspace == "blue" ? "green" : "blue"}"
    check_workspace   = "terraform workspace show"
    plan_changes      = "terraform plan"
  }
}

# =============================================================================
# 🔗 AWS CONSOLE LINKS
# =============================================================================
output "aws_console_links" {
  description = "Direct links to AWS Console resources for this environment"
  value = {
    lambda_function    = "https://console.aws.amazon.com/lambda/home?region=${data.aws_region.current.name}#/functions/${aws_lambda_function.visitor_counter.function_name}"
    api_gateway       = "https://console.aws.amazon.com/apigateway/home?region=${data.aws_region.current.name}#/apis/${aws_api_gateway_rest_api.visitor_api.id}/stages/${aws_api_gateway_stage.api_stage.stage_name}"
    cloudwatch_dashboard = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.application_dashboard.dashboard_name}"
    lambda_logs       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.lambda_logs.name, "/", "$252F")}"
    api_logs          = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.api_gateway_logs.name, "/", "$252F")}"
    sns_topic         = "https://console.aws.amazon.com/sns/v3/home?region=${data.aws_region.current.name}#/topic/${aws_sns_topic.deployment_alerts.arn}"
    cloudwatch_alarms = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#alarmsV2:?search=${local.resource_suffix}"
  }
}

# =============================================================================
# 🗄️ PERSISTENT LAYER REFERENCES
# =============================================================================
output "dynamodb_table_name" {
  description = "DynamoDB table name (from persistent layer)"
  value       = data.terraform_remote_state.persistent.outputs.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN (from persistent layer)"
  value       = data.terraform_remote_state.persistent.outputs.dynamodb_table_arn
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN (from persistent layer)"
  value       = data.terraform_remote_state.persistent.outputs.lambda_execution_role_arn
}

output "persistent_layer_info" {
  description = "Information from persistent layer"
  value = {
    dynamodb_table_name = data.terraform_remote_state.persistent.outputs.dynamodb_table_name
    dynamodb_table_arn  = data.terraform_remote_state.persistent.outputs.dynamodb_table_arn
    lambda_role_arn     = data.terraform_remote_state.persistent.outputs.lambda_execution_role_arn
    website_bucket      = data.terraform_remote_state.persistent.outputs.website_bucket_name
    cloudfront_id       = data.terraform_remote_state.persistent.outputs.cloudfront_distribution_id
  }
}
