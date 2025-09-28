variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}

variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
}

variable "lambda_function_names" {
  description = "List of Lambda function names"
  type        = list(string)
}

variable "dynamodb_table_names" {
  description = "List of DynamoDB table names"
  type        = list(string)
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names"
  type        = list(string)
  default     = []
}

variable "alarm_email_endpoint" {
  description = "Email address for CloudWatch alarms"
  type        = string
  default     = ""
}

variable "api_error_threshold" {
  description = "Threshold for API Gateway 5XX errors"
  type        = number
  default     = 5
}

variable "lambda_error_threshold" {
  description = "Threshold for Lambda errors"
  type        = number
  default     = 3
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "enable_synthetics" {
  description = "Enable CloudWatch Synthetics canary"
  type        = bool
  default     = false
}

variable "synthetics_bucket" {
  description = "S3 bucket for Synthetics artifacts"
  type        = string
  default     = ""
}

variable "api_gateway_url" {
  description = "API Gateway URL for health checks"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}