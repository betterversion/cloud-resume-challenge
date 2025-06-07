# monitoring.tf - CloudWatch Log Groups

# Template for dashboard JSON
locals {
  dashboard_body = templatefile("${path.module}/../../monitoring/resume-counter-dashboard.tpl.json", {
    lambda_function_name = aws_lambda_function.visitor_counter.function_name
    api_gateway_name     = aws_api_gateway_rest_api.visitor_api.name
    api_stage_name       = terraform.workspace
    lambda_log_group     = local.lambda_log_group
    dynamodb_table_name  = data.terraform_remote_state.persistent.outputs.dynamodb_table_name
    aws_region          = data.aws_region.current.name
    environment         = local.environment
  })
}

# CloudWatch Dashboard (workspace-specific) ← YES, THIS GOES HERE!
resource "aws_cloudwatch_dashboard" "application_dashboard" {
  dashboard_name = "${local.resource_suffix}-dashboard"
  dashboard_body = local.dashboard_body
}

# CloudWatch Log Group for Lambda function (workspace-specific)
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = local.lambda_log_group
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name      = "${local.lambda_function_name}-logs"
    Component = "logging"
    Service   = "lambda"
  })
}

# Import your API Gateway execution logs
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.visitor_api.id}/${terraform.workspace}"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name      = "${local.api_name}-logs"
    Component = "logging"
    Service   = "api-gateway"
  })
}

# SNS Topic for alerts (workspace-specific)
resource "aws_sns_topic" "deployment_alerts" {
  name = "${local.resource_suffix}-deployment-alerts"

  tags = merge(local.common_tags, {
    Name      = "${local.resource_suffix}-alerts"
    Component = "monitoring"
    Service   = "sns"
  })
}

# Email subscription for alerts
resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.deployment_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Lambda Error Alarm (workspace-specific)
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.lambda_function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "Lambda function ${local.lambda_function_name} is experiencing errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.visitor_counter.function_name
  }

  alarm_actions = [aws_sns_topic.deployment_alerts.arn]

  tags = merge(local.common_tags, {
    Name      = "${local.lambda_function_name}-error-alarm"
    Component = "monitoring"
    Service   = "cloudwatch"
  })
}

# Lambda Duration Alarm (workspace-specific)
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${local.lambda_function_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "2500"  # 2.5 seconds (close to 3s timeout)
  alarm_description   = "Lambda function ${local.lambda_function_name} is running slow"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.visitor_counter.function_name
  }

  alarm_actions = [aws_sns_topic.deployment_alerts.arn]

  tags = merge(local.common_tags, {
    Name      = "${local.lambda_function_name}-duration-alarm"
    Component = "monitoring"
  })
}

# API Gateway 4XX Errors (workspace-specific)
resource "aws_cloudwatch_metric_alarm" "api_client_errors" {
  alarm_name          = "${local.api_name}-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Spike in API client errors for ${local.api_name}"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.visitor_api.name
    Stage   = terraform.workspace
  }

  alarm_actions = [aws_sns_topic.deployment_alerts.arn]

  tags = merge(local.common_tags, {
    Name      = "${local.api_name}-4xx-alarm"
    Component = "monitoring"
  })
}

# API Gateway 5XX Errors (workspace-specific)
resource "aws_cloudwatch_metric_alarm" "api_server_errors" {
  alarm_name          = "${local.api_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Server errors detected for ${local.api_name}"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.visitor_api.name
    Stage   = terraform.workspace
  }

  alarm_actions = [aws_sns_topic.deployment_alerts.arn]

  tags = merge(local.common_tags, {
    Name      = "${local.api_name}-5xx-alarm"
    Component = "monitoring"
  })
}

# API Gateway Latency Alarm (workspace-specific)
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${local.api_name}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Average"
  threshold           = "1000"
  alarm_description   = "API responses are slow for ${local.api_name}"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.visitor_api.name
    Stage   = terraform.workspace
  }

  alarm_actions = [aws_sns_topic.deployment_alerts.arn]

  tags = merge(local.common_tags, {
    Name      = "${local.api_name}-latency-alarm"
    Component = "monitoring"
  })
}
