variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "enable_username_login" {
  description = "Enable username-based login"
  type        = bool
  default     = true
}

variable "enable_email_login" {
  description = "Enable email-based login"
  type        = bool
  default     = true
}

variable "enable_phone_login" {
  description = "Enable phone-based login"
  type        = bool
  default     = false
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_uppercase = bool
    require_numbers   = bool
    require_symbols   = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}

variable "enable_mfa" {
  description = "Enable Multi-Factor Authentication"
  type        = bool
  default     = false
}

variable "frontend_callback_urls" {
  description = "Callback URLs for frontend application"
  type        = list(string)
  default     = []
}

variable "enable_identity_pool" {
  description = "Enable Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "enable_lambda_triggers" {
  description = "Enable Lambda triggers for user pool"
  type        = bool
  default     = false
}

variable "pre_signup_lambda_arn" {
  description = "ARN of Lambda function for pre-signup trigger"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}