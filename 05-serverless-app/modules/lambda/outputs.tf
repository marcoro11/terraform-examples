output "auth_register_function_arn" {
  description = "ARN of the auth register Lambda function"
  value       = aws_lambda_function.auth_register.arn
}

output "auth_register_function_name" {
  description = "Name of the auth register Lambda function"
  value       = aws_lambda_function.auth_register.function_name
}

output "auth_login_function_arn" {
  description = "ARN of the auth login Lambda function"
  value       = aws_lambda_function.auth_login.arn
}

output "auth_login_function_name" {
  description = "Name of the auth login Lambda function"
  value       = aws_lambda_function.auth_login.function_name
}

output "auth_refresh_function_arn" {
  description = "ARN of the auth refresh Lambda function"
  value       = aws_lambda_function.auth_refresh.arn
}

output "auth_refresh_function_name" {
  description = "Name of the auth refresh Lambda function"
  value       = aws_lambda_function.auth_refresh.function_name
}

output "auth_logout_function_arn" {
  description = "ARN of the auth logout Lambda function"
  value       = aws_lambda_function.auth_logout.arn
}

output "auth_logout_function_name" {
  description = "Name of the auth logout Lambda function"
  value       = aws_lambda_function.auth_logout.function_name
}

output "users_list_function_arn" {
  description = "ARN of the users list Lambda function"
  value       = aws_lambda_function.users_list.arn
}

output "users_list_function_name" {
  description = "Name of the users list Lambda function"
  value       = aws_lambda_function.users_list.function_name
}

output "users_get_function_arn" {
  description = "ARN of the users get Lambda function"
  value       = aws_lambda_function.users_get.arn
}

output "users_get_function_name" {
  description = "Name of the users get Lambda function"
  value       = aws_lambda_function.users_get.function_name
}

output "users_create_function_arn" {
  description = "ARN of the users create Lambda function"
  value       = aws_lambda_function.users_create.arn
}

output "users_create_function_name" {
  description = "Name of the users create Lambda function"
  value       = aws_lambda_function.users_create.function_name
}

output "users_update_function_arn" {
  description = "ARN of the users update Lambda function"
  value       = aws_lambda_function.users_update.arn
}

output "users_update_function_name" {
  description = "Name of the users update Lambda function"
  value       = aws_lambda_function.users_update.function_name
}

output "users_delete_function_arn" {
  description = "ARN of the users delete Lambda function"
  value       = aws_lambda_function.users_delete.arn
}

output "users_delete_function_name" {
  description = "Name of the users delete Lambda function"
  value       = aws_lambda_function.users_delete.function_name
}

output "files_list_function_arn" {
  description = "ARN of the files list Lambda function"
  value       = aws_lambda_function.files_list.arn
}

output "files_list_function_name" {
  description = "Name of the files list Lambda function"
  value       = aws_lambda_function.files_list.function_name
}

output "files_upload_function_arn" {
  description = "ARN of the files upload Lambda function"
  value       = aws_lambda_function.files_upload.arn
}

output "files_upload_function_name" {
  description = "Name of the files upload Lambda function"
  value       = aws_lambda_function.files_upload.function_name
}

output "files_download_function_arn" {
  description = "ARN of the files download Lambda function"
  value       = aws_lambda_function.files_download.arn
}

output "files_download_function_name" {
  description = "Name of the files download Lambda function"
  value       = aws_lambda_function.files_download.function_name
}

output "files_delete_function_arn" {
  description = "ARN of the files delete Lambda function"
  value       = aws_lambda_function.files_delete.arn
}

output "files_delete_function_name" {
  description = "Name of the files delete Lambda function"
  value       = aws_lambda_function.files_delete.function_name
}

output "health_function_arn" {
  description = "ARN of the health Lambda function"
  value       = aws_lambda_function.health.arn
}

output "health_function_name" {
  description = "Name of the health Lambda function"
  value       = aws_lambda_function.health.function_name
}

output "all_function_names" {
  description = "Names of all Lambda functions"
  value = [
    aws_lambda_function.auth_register.function_name,
    aws_lambda_function.auth_login.function_name,
    aws_lambda_function.auth_refresh.function_name,
    aws_lambda_function.auth_logout.function_name,
    aws_lambda_function.users_list.function_name,
    aws_lambda_function.users_get.function_name,
    aws_lambda_function.users_create.function_name,
    aws_lambda_function.users_update.function_name,
    aws_lambda_function.users_delete.function_name,
    aws_lambda_function.files_list.function_name,
    aws_lambda_function.files_upload.function_name,
    aws_lambda_function.files_download.function_name,
    aws_lambda_function.files_delete.function_name,
    aws_lambda_function.health.function_name
  ]
}

output "all_function_arns" {
  description = "ARNs of all Lambda functions"
  value = [
    aws_lambda_function.auth_register.arn,
    aws_lambda_function.auth_login.arn,
    aws_lambda_function.auth_refresh.arn,
    aws_lambda_function.auth_logout.arn,
    aws_lambda_function.users_list.arn,
    aws_lambda_function.users_get.arn,
    aws_lambda_function.users_create.arn,
    aws_lambda_function.users_update.arn,
    aws_lambda_function.users_delete.arn,
    aws_lambda_function.files_list.arn,
    aws_lambda_function.files_upload.arn,
    aws_lambda_function.files_download.arn,
    aws_lambda_function.files_delete.arn,
    aws_lambda_function.health.arn
  ]
}