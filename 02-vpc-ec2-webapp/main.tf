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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  
  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
  enable_flow_logs   = var.enable_flow_logs
  
  tags = local.common_tags
}

module "security" {
  source = "./modules/security"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  tags = local.common_tags
}

module "compute" {
  source = "./modules/compute"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  
  alb_security_group_id    = module.security.alb_security_group_id
  web_security_group_id    = module.security.web_security_group_id
  bastion_security_group_id = module.security.bastion_security_group_id
  
  instance_type        = var.instance_type
  key_pair_name       = var.key_pair_name
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  
  database_endpoint = module.database.rds_endpoint
  redis_endpoint    = module.database.redis_endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
  
  tags = local.common_tags
  
  depends_on = [module.vpc, module.security]
}

module "database" {
  source = "./modules/database"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  database_subnet_ids  = module.vpc.database_subnet_ids
  database_subnet_group_name = module.vpc.database_subnet_group_name
  redis_subnet_group_name    = module.vpc.redis_subnet_group_name
  
  database_security_group_id = module.security.database_security_group_id
  redis_security_group_id    = module.security.redis_security_group_id
  
  db_instance_class    = var.db_instance_class
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  
  redis_node_type     = var.redis_node_type
  redis_num_cache_nodes = var.redis_num_cache_nodes
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  tags = local.common_tags
  
  depends_on = [module.vpc, module.security]
}

module "monitoring" {
  source = "./modules/monitoring"
  
  project_name = var.project_name
  environment  = var.environment
  
  alb_arn                = module.compute.alb_arn
  auto_scaling_group_name = module.compute.auto_scaling_group_name
  rds_instance_id        = module.database.rds_instance_id
  redis_cluster_id       = module.database.redis_cluster_id
  
  sns_email_endpoint = var.sns_email_endpoint
  
  tags = local.common_tags
  
  depends_on = [module.compute, module.database]
}

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = data.aws_caller_identity.current.user_id
    Region      = data.aws_region.current.name
  })
}