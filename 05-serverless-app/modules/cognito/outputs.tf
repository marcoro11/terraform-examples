output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "user_pool_domain" {
  description = "Cognito User Pool Domain"
  value       = aws_cognito_user_pool_domain.main.domain
}

output "user_pool_endpoint" {
  description = "Cognito User Pool Endpoint"
  value       = aws_cognito_user_pool.main.endpoint
}

output "identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = var.enable_identity_pool ? aws_cognito_identity_pool.main[0].id : null
}

output "authenticated_role_arn" {
  description = "IAM role ARN for authenticated users"
  value       = var.enable_identity_pool ? aws_iam_role.authenticated[0].arn : null
}