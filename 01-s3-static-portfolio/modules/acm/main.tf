terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_acm_certificate" "ssl_certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = var.validation_method

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}