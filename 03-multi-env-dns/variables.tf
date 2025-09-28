variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "root_domain" {
  description = "Root domain name (e.g., example.com)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]\\.[a-z]{2,}$", var.root_domain))
    error_message = "Root domain must be a valid domain format."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_waf" {
  description = "Enable AWS WAF for CloudFront"
  type        = bool
  default     = false
}

variable "enable_shield" {
  description = "Enable AWS Shield Advanced"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email for CloudWatch alarms and notifications"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "custom_instance_type" {
  description = "Override default instance type for environment"
  type        = string
  default     = ""
}

variable "custom_min_size" {
  description = "Override default minimum ASG size"
  type        = number
  default     = null
}

variable "custom_max_size" {
  description = "Override default maximum ASG size"
  type        = number
  default     = null
}

variable "custom_db_instance_class" {
  description = "Override default RDS instance class"
  type        = string
  default     = ""
}