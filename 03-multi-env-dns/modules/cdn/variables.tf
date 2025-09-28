variable "domain_name" {
  description = "Domain name for the CloudFront distribution"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for SSL/TLS"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "S3 bucket domain name for static content"
  type        = string
}

variable "alb_domain_name" {
  description = "ALB domain name for dynamic content (optional)"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200",
      "PriceClass_100"
    ], var.price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "enable_edge_functions" {
  description = "Enable CloudFront Functions for edge processing"
  type        = bool
  default     = false
}

variable "waf_acl_arn" {
  description = "WAF ACL ARN to attach to CloudFront (optional)"
  type        = string
  default     = ""
}

variable "create_invalidation" {
  description = "Create CloudFront invalidation on deployment"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}