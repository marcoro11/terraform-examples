output "website_url" {
  description = "Full website URL"
  value       = "https://${var.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = module.cloudfront.distribution_hosted_zone_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_website.bucket_id
}

output "s3_bucket_website_endpoint" {
  description = "Website endpoint of S3 bucket"
  value       = module.s3_website.bucket_website_endpoint
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.ssl_certificate.certificate_arn
}

output "route53_record_name" {
  description = "Route53 record name"
  value       = module.route53.record_name
}

output "deployment_commands" {
  description = "Commands to deploy your website"
  value = {
    sync_files    = "aws s3 sync ./website/ s3://${module.s3_website.bucket_id}/"
    invalidate_cache = "aws cloudfront create-invalidation --distribution-id ${module.cloudfront.distribution_id} --paths '/*'"
  }
}