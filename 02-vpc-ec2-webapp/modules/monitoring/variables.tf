variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "rds_instance_id" {
  description = "ID of the RDS instance"
  type        = string
}

variable "redis_cluster_id" {
  description = "ID of the Redis cluster"
  type        = string
}

variable "sns_email_endpoint" {
  description = "Email address for SNS notifications"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}