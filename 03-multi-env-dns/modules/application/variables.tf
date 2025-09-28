variable "environment" {
  description = "Environment name"
  type        = string
}

variable "full_domain" {
  description = "Full domain name for this environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "backup_retention" {
  description = "Database backup retention period in days"
  type        = number
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
}

variable "cloudfront_oai_id" {
  description = "CloudFront Origin Access Identity ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}