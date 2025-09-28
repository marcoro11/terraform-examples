terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

module "s3_website" {
  source = "./modules/s3-website"
  
  domain_name     = var.domain_name
  environment     = var.environment
  bucket_suffix   = random_string.bucket_suffix.result
  enable_logging  = var.enable_logging
  
  tags = local.common_tags
}

module "cloudfront" {
  source = "./modules/cloudfront"
  
  domain_name           = var.domain_name
  s3_bucket_id         = module.s3_website.bucket_id
  s3_bucket_domain_name = module.s3_website.bucket_domain_name
  environment          = var.environment
  price_class          = var.price_class
  
  certificate_arn = module.ssl_certificate.certificate_arn
  
  tags = local.common_tags
  
  depends_on = [module.ssl_certificate]
}

module "ssl_certificate" {
  source = "./modules/acm"
  
  providers = {
    aws = aws.us-east-1
  }
  
  domain_name = var.domain_name
  environment = var.environment
  
  tags = local.common_tags
}

module "route53" {
  source = "./modules/route53"
  
  domain_name                    = var.domain_name
  cloudfront_distribution_id     = module.cloudfront.distribution_id
  cloudfront_domain_name         = module.cloudfront.distribution_domain_name
  cloudfront_hosted_zone_id      = module.cloudfront.distribution_hosted_zone_id
  
  tags = local.common_tags
  
  depends_on = [module.cloudfront]
}

locals {
  common_tags = merge(var.tags, {
    Project     = "static-portfolio"
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = data.aws_caller_identity.current.user_id
    Region      = data.aws_region.current.name
  })
}