variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_suffix" {
  description = "Random suffix for bucket names"
  type        = string
}

variable "enable_logging" {
  description = "Enable access logging"
  type        = bool
  default     = true
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for bucket policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}