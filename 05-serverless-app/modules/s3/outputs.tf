output "website_bucket_name" {
  description = "Name of the website S3 bucket"
  value       = var.enable_website_hosting ? aws_s3_bucket.website[0].bucket : null
}

output "website_bucket_arn" {
  description = "ARN of the website S3 bucket"
  value       = var.enable_website_hosting ? aws_s3_bucket.website[0].arn : null
}

output "files_bucket_name" {
  description = "Name of the files S3 bucket"
  value       = aws_s3_bucket.files.bucket
}

output "files_bucket_arn" {
  description = "ARN of the files S3 bucket"
  value       = aws_s3_bucket.files.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_website_hosting ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.enable_website_hosting ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "website_url" {
  description = "Website URL"
  value       = var.enable_website_hosting ? (var.domain_name != "" ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.website[0].domain_name}") : null
}