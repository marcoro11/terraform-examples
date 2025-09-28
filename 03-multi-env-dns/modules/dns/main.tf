terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}

data "aws_route53_zone" "existing" {
  count = 1
  name  = var.root_domain
  private_zone = false
}

resource "aws_route53_zone" "main" {
  count = length(try(data.aws_route53_zone.existing[0].zone_id, "")) == 0 ? 1 : 0
  name  = var.root_domain
  
  tags = merge(var.tags, {
    Name = var.root_domain
  })
}

locals {
  hosted_zone_id = try(data.aws_route53_zone.existing[0].zone_id, aws_route53_zone.main[0].zone_id)
}

resource "aws_acm_certificate" "main" {
  provider = aws.us-east-1
  
  domain_name       = var.full_domain
  validation_method = "DNS"
  
  subject_alternative_names = var.environment == "prod" ? [
    "www.${var.root_domain}"
  ] : []
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.full_domain}"
  })
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.hosted_zone_id
}

resource "aws_acm_certificate_validation" "main" {
  provider = aws.us-east-1
  
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  
  timeouts {
    create = "5m"
  }
}

resource "aws_route53_record" "dmarc" {
  count = var.environment == "prod" ? 1 : 0
  
  zone_id = local.hosted_zone_id
  name    = "_dmarc.${var.root_domain}"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc@${var.root_domain}"]
}

resource "aws_route53_record" "spf" {
  count = var.environment == "prod" ? 1 : 0
  
  zone_id = local.hosted_zone_id
  name    = var.root_domain
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:_spf.google.com ~all"]
}

resource "aws_route53_record" "caa" {
  zone_id = local.hosted_zone_id
  name    = var.full_domain
  type    = "CAA"
  ttl     = 300
  records = [
    "0 issue \"amazon.com\"",
    "0 issue \"amazontrust.com\"",
    "0 issue \"awstrust.com\"",
    "0 issue \"amazonaws.com\""
  ]
}