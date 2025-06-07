# iam-application.tf
# Purpose: give the Lambda role DynamoDB rights (and future S3 / SES, etc.)

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "ResumeVisitorCounterDynamoDBAccess"

  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = aws_dynamodb_table.visitor_counter.arn
    }]
  })
}
