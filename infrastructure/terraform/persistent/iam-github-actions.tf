resource "aws_iam_role" "github_actions_deploy" {
  name = "GitHubActions-CloudResumeChallenge-Deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:betterversion/cloud-resume-challenge:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "GitHub Actions OIDC Deploy Role"
    Environment = "persistent"
  }
}

resource "aws_iam_policy" "github_actions_permissions" {
  name = "GitHubActionsMinimalPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Terraform backend and IAM support
      {
        Effect = "Allow",
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:PassRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      # S3 full operations (including read operations)
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = [
          "arn:aws:s3:::dzresume-prod",
          "arn:aws:s3:::dzresume-prod/*",
          aws_s3_bucket.tf_state.arn,
          "${aws_s3_bucket.tf_state.arn}/*",
          "arn:aws:s3:::dzresume-logs-prod",
          "arn:aws:s3:::dzresume-logs-prod/*"
        ]
      },
      # CloudFront operations (including read operations)
      {
        Effect   = "Allow",
        Action   = ["cloudfront:*"],
        Resource = "*"
      },
      # ACM Certificate operations
      {
        Effect   = "Allow",
        Action   = ["acm:*"],
        Resource = "*"
      },
      # Lambda deploy & update
      {
        Effect   = "Allow",
        Action   = ["lambda:*"],
        Resource = "*"
      },
      # API Gateway deploy & update
      {
        Effect   = "Allow",
        Action   = ["apigateway:*"],
        Resource = "*"
      },
      # DynamoDB operations (including read operations)
      {
        Effect   = "Allow",
        Action   = ["dynamodb:*"],
        Resource = "*"
      },
      # CloudWatch - Full access (for monitoring)
      {
        Effect   = "Allow",
        Action   = ["logs:*", "cloudwatch:*"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["sns:*"],
        Resource = "*"
      }
    ]
  })
}

# 🔗 Attach policy to role
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_permissions.arn
}
