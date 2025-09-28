output "users_table_name" {
  description = "Name of the users table"
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "ARN of the users table"
  value       = aws_dynamodb_table.users.arn
}

output "files_table_name" {
  description = "Name of the files table"
  value       = aws_dynamodb_table.files.name
}

output "files_table_arn" {
  description = "ARN of the files table"
  value       = aws_dynamodb_table.files.arn
}

output "sessions_table_name" {
  description = "Name of the sessions table"
  value       = aws_dynamodb_table.sessions.name
}

output "sessions_table_arn" {
  description = "ARN of the sessions table"
  value       = aws_dynamodb_table.sessions.arn
}

output "all_table_arns" {
  description = "ARNs of all DynamoDB tables"
  value = [
    aws_dynamodb_table.users.arn,
    aws_dynamodb_table.files.arn,
    aws_dynamodb_table.sessions.arn
  ]
}

output "all_table_names" {
  description = "Names of all DynamoDB tables"
  value = [
    aws_dynamodb_table.users.name,
    aws_dynamodb_table.files.name,
    aws_dynamodb_table.sessions.name
  ]
}