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

locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
  
  env_config = {
    dev = {
      instance_type        = "t3.micro"
      min_size            = 1
      max_size            = 2
      desired_capacity    = 1
      db_instance_class   = "db.t3.micro"
      domain_prefix       = "dev"
      enable_monitoring   = false
      backup_retention    = 1
    }
    staging = {
      instance_type        = "t3.small"
      min_size            = 2
      max_size            = 4
      desired_capacity    = 2
      db_instance_class   = "db.t3.small"
      domain_prefix       = "staging"
      enable_monitoring   = true
      backup_retention    = 3
    }
    prod = {
      instance_type        = "t3.medium"
      min_size            = 3
      max_size            = 10
      desired_capacity    = 3
      db_instance_class   = "db.t3.medium"
      domain_prefix       = ""  # apex domain
      enable_monitoring   = true
      backup_retention    = 30
    }
  }
  
  current_env = local.env_config[local.environment]
  
  full_domain = local.current_env.domain_prefix != "" ? "${local.current_env.domain_prefix}.${var.root_domain}" : var.root_domain
  
  common_tags = merge(var.tags, {
    Environment = local.environment
    Domain      = local.full_domain
    ManagedBy   = "terraform"
    Workspace   = terraform.workspace
    CreatedBy   = data.aws_caller_identity.current.user_id
  })
}

module "dns" {
  source = "./modules/dns"
  
  root_domain    = var.root_domain
  full_domain    = local.full_domain
  environment    = local.environment
  domain_prefix  = local.current_env.domain_prefix
  
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
  
  tags = local.common_tags
}

module "cdn" {
  source = "./modules/cdn"
  
  domain_name     = local.full_domain
  environment     = local.environment
  certificate_arn = module.dns.certificate_arn
  
  s3_bucket_domain_name = module.application.s3_bucket_domain_name
  
  price_class = local.environment == "prod" ? "PriceClass_All" : "PriceClass_100"
  
  tags = local.common_tags
  
  depends_on = [module.dns]
}

module "application" {
  source = "./modules/application"
  
  environment    = local.environment
  full_domain    = local.full_domain
  
  instance_type     = local.current_env.instance_type
  min_size         = local.current_env.min_size
  max_size         = local.current_env.max_size
  desired_capacity = local.current_env.desired_capacity
  
  db_instance_class = local.current_env.db_instance_class
  backup_retention  = local.current_env.backup_retention
  
  enable_monitoring = local.current_env.enable_monitoring
  
  vpc_cidr = var.vpc_cidr
  
  cloudfront_oai_id = module.cdn.origin_access_identity_id
  
  tags = local.common_tags
}

resource "aws_route53_record" "main" {
  zone_id = module.dns.hosted_zone_id
  name    = local.full_domain
  type    = "A"
  
  alias {
    name                   = module.cdn.distribution_domain_name
    zone_id               = module.cdn.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  count = local.environment == "prod" ? 1 : 0
  
  zone_id = module.dns.hosted_zone_id
  name    = "www.${var.root_domain}"
  type    = "A"
  
  alias {
    name                   = module.cdn.distribution_domain_name
    zone_id               = module.cdn.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_health_check" "main" {
  count = local.environment == "prod" ? 1 : 0
  
  fqdn                            = local.full_domain
  port                            = 443
  type                            = "HTTPS"
  resource_path                   = "/"
  failure_threshold               = 3
  request_interval                = 30
  cloudwatch_alarm_region         = var.aws_region
  cloudwatch_alarm_name           = "${local.environment}-${local.full_domain}-health"
  insufficient_data_health_status = "Unhealthy"
  
  tags = merge(local.common_tags, {
    Name = "${local.environment}-health-check"
  })
}