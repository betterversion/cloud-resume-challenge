variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "crc-prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "resume"
}

variable "lambda_function_name" {
  description = "Base name for Lambda function"
  type        = string
  default     = "resume-visitor-counter"
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = "dmitriy.z.tech@gmail.com"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}
