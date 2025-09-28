resource "aws_wafv2_web_acl" "main" {
  name  = "${var.app_name}-waf-${var.stage}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limiting"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-rate-limiting-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "sql-injection-protection"
    priority = 2

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-sql-injection-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "xss-protection"
    priority = 3

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesXSSRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-xss-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "common-attacks"
    priority = 4

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-common-attacks-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "bad-bot-protection"
    priority = 5

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-bad-bots-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ip-reputation"
    priority = 6

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-ip-reputation-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-waf-${var.stage}"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "api_gateway" {
  resource_arn = var.api_gateway_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "${var.app_name}-waf-blocked-${var.stage}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "WAF blocked requests > 10 in 10 minutes"
  alarm_actions       = var.alarm_email_endpoint != "" ? [aws_sns_topic.waf_alerts[0].arn] : []

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = data.aws_region.current.name
  }

  tags = var.tags
}

resource "aws_sns_topic" "waf_alerts" {
  count = var.alarm_email_endpoint != "" ? 1 : 0

  name = "${var.app_name}-waf-alerts-${var.stage}"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "waf_email" {
  count = var.alarm_email_endpoint != "" ? 1 : 0

  topic_arn = aws_sns_topic.waf_alerts[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email_endpoint
}

data "aws_region" "current" {}