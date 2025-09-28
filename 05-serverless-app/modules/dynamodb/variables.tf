variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "users_table_config" {
  description = "Users table configuration"
  type = object({
    read_capacity  = number
    write_capacity = number
  })
  default = {
    read_capacity  = 5
    write_capacity = 5
  }
}

variable "files_table_config" {
  description = "Files table configuration"
  type = object({
    read_capacity  = number
    write_capacity = number
  })
  default = {
    read_capacity  = 5
    write_capacity = 5
  }
}

variable "sessions_table_config" {
  description = "Sessions table configuration"
  type = object({
    read_capacity  = number
    write_capacity = number
  })
  default = {
    read_capacity  = 5
    write_capacity = 5
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "create_vpc_endpoint" {
  description = "Create VPC endpoint for DynamoDB"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for VPC endpoint"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}