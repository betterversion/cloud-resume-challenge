variable "active_environment" {
  description = "Which environment is active in CloudFront"
  type        = string
  default     = "blue"

  validation {
    condition     = contains(["blue", "green"], var.active_environment)
    error_message = "Active environment must be either 'blue' or 'green'."
  }
}

variable "aws_profile" {
  description = "AWS profile for local development"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "resume"
}

variable "domain_name" {
  description = "Domain name for the resume website"
  type        = string
  default     = "dzresume.dev"
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = "dmitriy.z.tech@gmail.com"
}
