output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "api_gateway_stage_url" {
  description = "URL of the API Gateway stage"
  value       = module.api_gateway.api_gateway_stage_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_gateway_id
}

output "api_custom_domain_url" {
  description = "Custom domain URL for API"
  value       = var.api_domain_name != "" ? "https://${var.api_domain_name}" : null
}

output "website_url" {
  description = "URL of the frontend website"
  value       = var.enable_frontend && var.domain_name != "" ? "https://${var.domain_name}" : null
}

output "website_bucket_name" {
  description = "S3 bucket name for website hosting"
  value       = var.enable_frontend ? module.s3.website_bucket_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_frontend ? module.s3.cloudfront_distribution_id : null
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.cognito.user_pool_client_id
}

output "cognito_user_pool_domain" {
  description = "Cognito User Pool Domain"
  value       = module.cognito.user_pool_domain
}

output "dynamodb_tables" {
  description = "DynamoDB table information"
  value = {
    users_table    = module.dynamodb.users_table_name
    files_table    = module.dynamodb.files_table_name
    sessions_table = module.dynamodb.sessions_table_name
  }
}

output "s3_buckets" {
  description = "S3 bucket information"
  value = {
    files_bucket   = module.s3.files_bucket_name
    website_bucket = var.enable_frontend ? module.s3.website_bucket_name : null
  }
}

output "lambda_functions" {
  description = "Lambda function information"
  value       = module.lambda.all_function_names
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups"
  value       = module.monitoring.log_group_names
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID (if enabled)"
  value       = var.stage == "prod" && var.enable_waf ? module.waf[0].web_acl_id : null
}

output "deployment_commands" {
  description = "Commands for deploying application code"
  value = {
    package_functions = "cd lambda-functions && ./package-functions.sh"
    deploy_functions  = "./scripts/deploy-functions.sh"
    deploy_frontend   = var.enable_frontend ? "./scripts/deploy-frontend.sh" : null
    invalidate_cache  = var.enable_frontend ? "aws cloudfront create-invalidation --distribution-id ${module.s3.cloudfront_distribution_id} --paths '/*'" : null
  }
}

output "testing_commands" {
  description = "Commands for testing the API"
  value = {
    health_check   = "curl ${module.api_gateway.api_gateway_url}/health"
    create_user    = "curl -X POST ${module.api_gateway.api_gateway_url}/users -H 'Content-Type: application/json' -d '{\"name\":\"test\",\"email\":\"test@example.com\"}'"
    list_users     = "curl ${module.api_gateway.api_gateway_url}/users"
    api_docs       = "${module.api_gateway.api_gateway_url}/docs"
  }
}

output "environment_config" {
  description = "Environment configuration for frontend"
  value = {
    REACT_APP_API_URL          = module.api_gateway.api_gateway_url
    REACT_APP_REGION           = var.aws_region
    REACT_APP_USER_POOL_ID     = module.cognito.user_pool_id
    REACT_APP_USER_POOL_CLIENT_ID = module.cognito.user_pool_client_id
    REACT_APP_STAGE            = var.stage
  }
  sensitive = false
}

output "connection_info" {
  description = "Connection information for the application"
  value = {
    api_endpoint     = module.api_gateway.api_gateway_url
    frontend_url     = var.enable_frontend && var.domain_name != "" ? "https://${var.domain_name}" : "Deploy frontend to S3 bucket: ${module.s3.website_bucket_name}"
    auth_login_url   = "${module.cognito.user_pool_domain}/login?client_id=${module.cognito.user_pool_client_id}&response_type=code&scope=openid+email+profile"
    dashboard_url    = module.monitoring.dashboard_url
  }
}