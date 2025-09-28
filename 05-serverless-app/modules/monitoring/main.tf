resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard-${var.stage}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_name, "Method", "GET", "Resource", "/health", "Stage", var.stage],
            [".", "Count", ".", ".", "Method", "POST", "Resource", "/auth/login", "Stage", var.stage],
            [".", "Count", ".", ".", "Method", "GET", "Resource", "/users", "Stage", var.stage]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "API Gateway Requests"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiName", var.api_gateway_name, "Stage", var.stage],
            [".", "5XXError", ".", ".", "Stage", var.stage]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "API Gateway Errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names[0], { "stat": "Sum" }],
            [".", "Errors", "FunctionName", var.lambda_function_names[1], { "stat": "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Lambda Errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_names[0], { "stat": "Average" }],
            [".", "Duration", "FunctionName", var.lambda_function_names[1], { "stat": "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Lambda Duration"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_names[0], { "stat": "Sum" }],
            [".", "ConsumedWriteCapacityUnits", ".", ".", { "stat": "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "DynamoDB Capacity Units"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/S3", "AllRequests", "BucketName", var.s3_bucket_names[0], "FilterId", "EntireBucket"],
            [".", "AllRequests", "BucketName", var.s3_bucket_names[1], "FilterId", "EntireBucket"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "S3 Requests"
          period  = 300
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "${var.app_name}-api-5xx-errors-${var.stage}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.api_error_threshold
  alarm_description   = "API Gateway 5XX errors > ${var.api_error_threshold} in 10 minutes"
  alarm_actions       = var.alarm_email_endpoint != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.stage
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.app_name}-lambda-errors-${var.stage}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  alarm_description   = "Lambda errors > ${var.lambda_error_threshold} in 10 minutes"
  alarm_actions       = var.alarm_email_endpoint != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    FunctionName = var.lambda_function_names[0]
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.app_name}-dynamodb-throttles-${var.stage}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "DynamoDB throttled requests > 5 in 5 minutes"
  alarm_actions       = var.alarm_email_endpoint != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    TableName = var.dynamodb_table_names[0]
  }

  tags = var.tags
}

resource "aws_sns_topic" "alerts" {
  count = var.alarm_email_endpoint != "" ? 1 : 0

  name = "${var.app_name}-alerts-${var.stage}"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alarm_email_endpoint != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email_endpoint
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/${var.app_name}-${var.stage}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = toset(var.lambda_function_names)

  name              = "/aws/lambda/${each.value}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "api_errors" {
  name           = "${var.app_name}-api-errors-${var.stage}"
  pattern        = "\"ERROR\""
  log_group_name = aws_cloudwatch_log_group.api_gateway.name

  metric_transformation {
    name      = "${var.app_name}-api-errors-${var.stage}"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_synthetics_canary" "api_health" {
  count = var.enable_synthetics ? 1 : 0

  name                 = "${var.app_name}-api-health-${var.stage}"
  artifact_s3_location = "s3://${var.synthetics_bucket}/canary/${var.app_name}"
  execution_role_arn   = aws_iam_role.synthetics[0].arn
  handler              = "apiHealth.handler"
  runtime_version      = "syn-nodejs-puppeteer-3.9"
  start_canary         = true

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  zip_file = data.archive_file.canary_zip[0].output_path

  tags = var.tags
}

resource "aws_iam_role" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  name = "${var.app_name}-synthetics-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/CloudWatchSyntheticsFullAccess"
  role       = aws_iam_role.synthetics[0].name
}

data "archive_file" "canary_zip" {
  count = var.enable_synthetics ? 1 : 0

  type        = "zip"
  output_path = "/tmp/${var.app_name}-canary-${var.stage}.zip"

  source {
    content  = <<-EOF
const synthetics = require('Synthetics');
const https = require('https');

const apiCanaryBlueprint = async function () {
    const apiUrl = '${var.api_gateway_url}';

    const page = await synthetics.getPage();

    const response = await page.goto(apiUrl + '/health', {
        waitUntil: 'domcontentloaded',
        timeout: 30000
    });

    if (response.status() !== 200) {
        throw new Error('API health check failed with status: ' + response.status());
    }

    const responseText = await response.text();
    if (!responseText.includes('OK')) {
        throw new Error('API health check response not OK');
    }
};

exports.handler = async () => {
    return await apiCanaryBlueprint();
};
EOF
    filename = "apiHealth.js"
  }
}