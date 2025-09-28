variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "validation_method" {
  description = "ACM certificate validation method"
  type        = string
  default     = "DNS"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}