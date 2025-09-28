output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for static content"
  value       = aws_s3_bucket.static.bucket
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.static.bucket_regional_domain_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = var.environment != "dev" ? aws_db_instance.main[0].endpoint : null
}

output "rds_port" {
  description = "RDS port"
  value       = var.environment != "dev" ? aws_db_instance.main[0].port : null
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = var.enable_monitoring ? "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : null
}

data "aws_region" "current" {}