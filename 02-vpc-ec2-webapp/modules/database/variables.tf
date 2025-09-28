variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "database_subnet_ids" {
  description = "IDs of the database subnets"
  type        = list(string)
}

variable "database_security_group_id" {
  description = "ID of the database security group"
  type        = string
}

variable "redis_security_group_id" {
  description = "ID of the Redis security group"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes in the Redis cluster"
  type        = number
}

variable "backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
}

variable "backup_window" {
  description = "Database backup window"
  type        = string
}

variable "maintenance_window" {
  description = "Database maintenance window"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "database_subnet_group_name" {
  description = "Name of the database subnet group"
  type        = string
}

variable "redis_subnet_group_name" {
  description = "Name of the Redis subnet group"
  type        = string
}