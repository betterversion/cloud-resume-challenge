# API Gateway REST API - Foundation for blue-green deployment
resource "aws_api_gateway_rest_api" "visitor_api" {
  # Clean naming using local suffix
  name        = local.api_name
  description = "Visitor counter API for ${local.environment} environment with health monitoring"

  api_key_source = "HEADER"
  endpoint_configuration {
    types           = ["REGIONAL"]
    ip_address_type = "ipv4"
  }
  disable_execute_api_endpoint = false

  tags = merge(local.common_tags, {
    Name = local.api_name
  })
}

# Counter endpoint resource - handles visitor count requests
resource "aws_api_gateway_resource" "counter" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "counter"
}

# Health endpoint resource - handles health check requests
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "health"
}

# GET method for counter endpoint - handles visitor count retrieval
resource "aws_api_gateway_method" "counter_get" {
  rest_api_id      = aws_api_gateway_rest_api.visitor_api.id
  resource_id      = aws_api_gateway_resource.counter.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

# GET method for health endpoint - handles health check requests
resource "aws_api_gateway_method" "health_get" {
  rest_api_id      = aws_api_gateway_rest_api.visitor_api.id
  resource_id      = aws_api_gateway_resource.health.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS method for counter endpoint - handles CORS preflight requests
resource "aws_api_gateway_method" "counter_options" {
  rest_api_id      = aws_api_gateway_rest_api.visitor_api.id
  resource_id      = aws_api_gateway_resource.counter.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS method for health endpoint - handles CORS preflight requests
resource "aws_api_gateway_method" "health_options" {
  rest_api_id      = aws_api_gateway_rest_api.visitor_api.id
  resource_id      = aws_api_gateway_resource.health.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# Integration connecting counter GET method to Lambda function
resource "aws_api_gateway_integration" "counter_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.counter.id
  http_method = aws_api_gateway_method.counter_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"

  # Clean Lambda ARN using local suffix
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_function_name}/invocations"

  timeout_milliseconds = 29000
}

# Integration connecting health GET method to Lambda function
resource "aws_api_gateway_integration" "health_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"

  # Same clean Lambda ARN reference
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_function_name}/invocations"

  timeout_milliseconds = 29000
}

# Mock integration for counter OPTIONS method - handles CORS preflight
resource "aws_api_gateway_integration" "counter_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.counter.id
  http_method = aws_api_gateway_method.counter_options.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  timeout_milliseconds = 29000
}

# Mock integration for health OPTIONS method - handles CORS preflight
resource "aws_api_gateway_integration" "health_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_options.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  timeout_milliseconds = 29000
}

# Integration response for counter GET method - handles Lambda function responses
resource "aws_api_gateway_integration_response" "counter_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.counter.id
  http_method = aws_api_gateway_method.counter_get.http_method

  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.counter_get_integration,
    aws_api_gateway_method_response.counter_get_200
  ]
}

# Integration response for health GET method - handles Lambda function responses
resource "aws_api_gateway_integration_response" "health_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method

  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.health_get_integration]
}

# Integration response for counter OPTIONS method - handles CORS preflight responses
resource "aws_api_gateway_integration_response" "counter_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.counter.id
  http_method = aws_api_gateway_method.counter_options.http_method

  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.counter_options_integration]
}

# Integration response for health OPTIONS method - handles CORS preflight responses
resource "aws_api_gateway_integration_response" "health_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_options.http_method

  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.health_options_integration]
}

# Method response for counter GET - defines the API contract for successful responses
resource "aws_api_gateway_method_response" "counter_get_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.counter.id
  http_method = aws_api_gateway_method.counter_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Method response for health GET - defines the API contract for successful responses
resource "aws_api_gateway_method_response" "health_get_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Method response for counter OPTIONS - defines the API contract for CORS responses
resource "aws_api_gateway_method_response" "counter_options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.counter.id
  http_method = aws_api_gateway_method.counter_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Method response for health OPTIONS - defines the API contract for CORS responses
resource "aws_api_gateway_method_response" "health_options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway deployment - makes the API configuration live and accessible
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.counter.id,
      aws_api_gateway_resource.health.id,
      aws_api_gateway_method.counter_get.id,
      aws_api_gateway_method.health_get.id,
      aws_api_gateway_method.counter_options.id,
      aws_api_gateway_method.health_options.id,
      aws_api_gateway_integration.counter_get_integration.id,
      aws_api_gateway_integration.health_get_integration.id,
      aws_api_gateway_integration.counter_options_integration.id,
      aws_api_gateway_integration.health_options_integration.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_method.counter_get,
    aws_api_gateway_method.health_get,
    aws_api_gateway_method.counter_options,
    aws_api_gateway_method.health_options,
    aws_api_gateway_integration.counter_get_integration,
    aws_api_gateway_integration.health_get_integration,
    aws_api_gateway_integration.counter_options_integration,
    aws_api_gateway_integration.health_options_integration,
    aws_api_gateway_integration_response.counter_get_integration_response,
    aws_api_gateway_integration_response.health_get_integration_response,
    aws_api_gateway_integration_response.counter_options_integration_response,
    aws_api_gateway_integration_response.health_options_integration_response,
    aws_api_gateway_method_response.counter_get_200,
    aws_api_gateway_method_response.health_get_200,
    aws_api_gateway_method_response.counter_options_200,
    aws_api_gateway_method_response.health_options_200,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage - provides named environment and stable URL
resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id

  # Stage name still uses workspace directly (for URL path)
  stage_name = terraform.workspace

  tags = merge(local.common_tags, {
    Name = local.api_stage_name
  })
}

# Lambda permission for API Gateway to invoke the visitor counter function
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway-${local.environment}"
  action        = "lambda:InvokeFunction"

  # Clean function name reference
  function_name = local.lambda_function_name

  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/*"

  depends_on = [aws_api_gateway_rest_api.visitor_api]
}
