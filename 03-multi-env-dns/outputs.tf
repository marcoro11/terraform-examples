output "environment" {
  description = "Current environment"
  value       = local.environment
}

output "workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "full_domain" {
  description = "Full domain name for this environment"
  value       = local.full_domain
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = module.dns.hosted_zone_id
}

output "certificate_arn" {
  description = "SSL certificate ARN"
  value       = module.dns.certificate_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cdn.distribution_domain_name
}

output "application_urls" {
  description = "URLs to access the application"
  value = {
    primary = "https://${local.full_domain}"
    www     = local.environment == "prod" ? "https://www.${var.root_domain}" : null
    cdn     = "https://${module.cdn.distribution_domain_name}"
  }
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.application.vpc_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.application.alb_dns_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for static content"
  value       = module.application.s3_bucket_name
}

output "environment_config" {
  description = "Current environment configuration"
  value = {
    instance_type     = local.current_env.instance_type
    min_size         = local.current_env.min_size
    max_size         = local.current_env.max_size
    desired_capacity = local.current_env.desired_capacity
    db_instance_class = local.current_env.db_instance_class
    domain_prefix    = local.current_env.domain_prefix
    enable_monitoring = local.current_env.enable_monitoring
    backup_retention = local.current_env.backup_retention
  }
}

output "deployment_commands" {
  description = "Useful commands for this environment"
  value = {
    workspace_switch = "terraform workspace select ${local.environment}"
    plan_command     = "terraform plan -var-file='environments/${local.environment}.tfvars'"
    apply_command    = "terraform apply -var-file='environments/${local.environment}.tfvars'"
    destroy_command  = "terraform destroy -var-file='environments/${local.environment}.tfvars'"
    invalidate_cdn   = "aws cloudfront create-invalidation --distribution-id ${module.cdn.distribution_id} --paths '/*'"
  }
}

output "health_check_id" {
  description = "Route53 health check ID (prod only)"
  value       = local.environment == "prod" ? aws_route53_health_check.main[0].id : null
}

output "monitoring_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = local.current_env.enable_monitoring ? module.application.dashboard_url : null
}