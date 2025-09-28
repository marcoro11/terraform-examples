variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "api_gateway_arn" {
  description = "API Gateway stage ARN to associate WAF with"
  type        = string
}

variable "rate_limit" {
  description = "Rate limit for requests per 5 minutes"
  type        = number
  default     = 2000
}

variable "alarm_email_endpoint" {
  description = "Email address for WAF alarms"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}