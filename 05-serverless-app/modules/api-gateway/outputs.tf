output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_name" {
  description = "Name of the API Gateway"
  value       = aws_api_gateway_rest_api.main.name
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage}"
}

output "api_gateway_stage_url" {
  description = "URL of the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage}"
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.main.arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "custom_domain_url" {
  description = "Custom domain URL for API"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : null
}

output "api_key_id" {
  description = "API key ID (if enabled)"
  value       = var.enable_api_key ? aws_api_gateway_api_key.main[0].id : null
}

output "api_key_value" {
  description = "API key value (if enabled)"
  value       = var.enable_api_key ? aws_api_gateway_api_key.main[0].value : null
  sensitive   = true
}

output "usage_plan_id" {
  description = "Usage plan ID"
  value       = aws_api_gateway_usage_plan.main.id
}