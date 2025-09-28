variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "environment_variables" {
  description = "Environment variables for Lambda functions"
  type        = map(string)
  default     = {}
}

variable "dynamodb_table_arns" {
  description = "DynamoDB table ARNs for IAM permissions"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs for IAM permissions"
  type        = list(string)
  default     = []
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for IAM permissions"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}