variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "enable_website_hosting" {
  description = "Enable S3 website hosting with CloudFront"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Custom domain name for the website"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for custom domain"
  type        = string
  default     = ""
}

variable "enable_file_uploads" {
  description = "Enable S3 bucket for file uploads"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "enable_spa_routing" {
  description = "Enable CloudFront function for SPA routing"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}