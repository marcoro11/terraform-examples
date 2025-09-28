variable "root_domain" {
  description = "Root domain name"
  type        = string
}

variable "full_domain" {
  description = "Full domain name for this environment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_prefix" {
  description = "Domain prefix for environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}