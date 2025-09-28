variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "lambda_functions" {
  description = "Lambda function ARNs for API integrations"
  type = map(string)
}

variable "lambda_function_names" {
  description = "Lambda function names for permissions"
  type = map(string)
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for authorization"
  type        = string
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
}

variable "cors_allowed_headers" {
  description = "Allowed headers for CORS"
  type        = list(string)
  default     = ["Content-Type", "Authorization", "X-Api-Key"]
}

variable "cors_allowed_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "domain_name" {
  description = "Custom domain name for API"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "enable_api_key" {
  description = "Enable API key for rate limiting"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}