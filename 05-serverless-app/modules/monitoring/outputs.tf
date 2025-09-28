output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "log_group_names" {
  description = "CloudWatch log group names"
  value = concat(
    [aws_cloudwatch_log_group.api_gateway.name],
    [for lg in aws_cloudwatch_log_group.lambda : lg.name]
  )
}

output "alarm_names" {
  description = "CloudWatch alarm names"
  value = [
    aws_cloudwatch_metric_alarm.api_gateway_5xx_errors.alarm_name,
    aws_cloudwatch_metric_alarm.lambda_errors.alarm_name,
    aws_cloudwatch_metric_alarm.dynamodb_throttles.alarm_name
  ]
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = var.alarm_email_endpoint != "" ? aws_sns_topic.alerts[0].arn : null
}

output "synthetics_canary_name" {
  description = "CloudWatch Synthetics canary name"
  value       = var.enable_synthetics ? aws_synthetics_canary.api_health[0].name : null
}

data "aws_region" "current" {}