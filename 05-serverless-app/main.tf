terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3" {
  source = "./modules/s3"
  
  app_name     = var.app_name
  stage        = var.stage
  
  enable_website_hosting = var.enable_frontend
  domain_name           = var.domain_name
  
  enable_file_uploads = true
  cors_allowed_origins = var.cors_allowed_origins
  
  tags = local.common_tags
}

module "dynamodb" {
  source = "./modules/dynamodb"
  
  app_name = var.app_name
  stage    = var.stage
  
  users_table_config = {
    read_capacity  = var.stage == "prod" ? 10 : 5
    write_capacity = var.stage == "prod" ? 10 : 5
  }
  
  files_table_config = {
    read_capacity  = var.stage == "prod" ? 5 : 2
    write_capacity = var.stage == "prod" ? 5 : 2
  }
  
  sessions_table_config = {
    read_capacity  = var.stage == "prod" ? 5 : 2
    write_capacity = var.stage == "prod" ? 5 : 2
  }
  
  tags = local.common_tags
}

module "cognito" {
  source = "./modules/cognito"
  
  app_name = var.app_name
  stage    = var.stage
  
  enable_username_login = true
  enable_email_login    = true
  enable_phone_login    = false
  
  password_policy = {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
  
  frontend_callback_urls = var.enable_frontend ? [
    "https://${var.domain_name}/auth/callback",
    "http://localhost:3000/auth/callback"  # for local development
  ] : []
  
  tags = local.common_tags
}

module "lambda" {
  source = "./modules/lambda"
  
  app_name = var.app_name
  stage    = var.stage
  
  environment_variables = {
    STAGE                  = var.stage
    REGION                = data.aws_region.current.name
    USERS_TABLE           = module.dynamodb.users_table_name
    FILES_TABLE           = module.dynamodb.files_table_name
    SESSIONS_TABLE        = module.dynamodb.sessions_table_name
    FILES_BUCKET          = module.s3.files_bucket_name
    COGNITO_USER_POOL_ID  = module.cognito.user_pool_id
    COGNITO_CLIENT_ID     = module.cognito.user_pool_client_id
  }
  
  dynamodb_table_arns = [
    module.dynamodb.users_table_arn,
    module.dynamodb.files_table_arn,
    module.dynamodb.sessions_table_arn
  ]
  
  s3_bucket_arns = [
    module.s3.files_bucket_arn,
    module.s3.website_bucket_arn
  ]
  
  cognito_user_pool_arn = module.cognito.user_pool_arn
  
  tags = local.common_tags
  
  depends_on = [module.dynamodb, module.s3, module.cognito]
}

module "api_gateway" {
  source = "./modules/api-gateway"
  
  app_name = var.app_name
  stage    = var.stage
  
  lambda_functions = {
    auth_register = module.lambda.auth_register_function_arn
    auth_login    = module.lambda.auth_login_function_arn
    auth_refresh  = module.lambda.auth_refresh_function_arn
    auth_logout   = module.lambda.auth_logout_function_arn
    users_list    = module.lambda.users_list_function_arn
    users_get     = module.lambda.users_get_function_arn
    users_create  = module.lambda.users_create_function_arn
    users_update  = module.lambda.users_update_function_arn
    users_delete  = module.lambda.users_delete_function_arn
    files_list    = module.lambda.files_list_function_arn
    files_upload  = module.lambda.files_upload_function_arn
    files_download = module.lambda.files_download_function_arn
    files_delete  = module.lambda.files_delete_function_arn
    health        = module.lambda.health_function_arn
  }
  
  lambda_function_names = {
    auth_register = module.lambda.auth_register_function_name
    auth_login    = module.lambda.auth_login_function_name
    auth_refresh  = module.lambda.auth_refresh_function_name
    auth_logout   = module.lambda.auth_logout_function_name
    users_list    = module.lambda.users_list_function_name
    users_get     = module.lambda.users_get_function_name
    users_create  = module.lambda.users_create_function_name
    users_update  = module.lambda.users_update_function_name
    users_delete  = module.lambda.users_delete_function_name
    files_list    = module.lambda.files_list_function_name
    files_upload  = module.lambda.files_upload_function_name
    files_download = module.lambda.files_download_function_name
    files_delete  = module.lambda.files_delete_function_name
    health        = module.lambda.health_function_name
  }
  
  cors_allowed_origins = var.cors_allowed_origins
  cors_allowed_headers = ["Content-Type", "Authorization", "X-Api-Key"]
  cors_allowed_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  
  cognito_user_pool_arn = module.cognito.user_pool_arn
  
  domain_name     = var.api_domain_name
  certificate_arn = var.api_certificate_arn
  
  tags = local.common_tags
  
  depends_on = [module.lambda, module.cognito]
}

module "monitoring" {
  source = "./modules/monitoring"
  
  app_name = var.app_name
  stage    = var.stage
  
  api_gateway_id   = module.api_gateway.api_gateway_id
  api_gateway_name = module.api_gateway.api_gateway_name
  
  lambda_function_names = values(module.lambda.all_function_names)
  
  dynamodb_table_names = [
    module.dynamodb.users_table_name,
    module.dynamodb.files_table_name,
    module.dynamodb.sessions_table_name
  ]
  
  alarm_email_endpoint = var.alarm_email_endpoint
  
  api_error_threshold    = var.stage == "prod" ? 5 : 10
  lambda_error_threshold = var.stage == "prod" ? 3 : 5
  
  tags = local.common_tags
  
  depends_on = [module.api_gateway, module.lambda, module.dynamodb]
}

module "waf" {
  count = var.stage == "prod" && var.enable_waf ? 1 : 0
  
  source = "./modules/waf"
  
  app_name = var.app_name
  stage    = var.stage
  
  api_gateway_arn = module.api_gateway.api_gateway_stage_arn
  
  rate_limit = 2000  # requests per 5 minutes
  
  tags = local.common_tags
  
  depends_on = [module.api_gateway]
}

locals {
  common_tags = merge(var.tags, {
    Application = var.app_name
    Stage       = var.stage
    ManagedBy   = "terraform"
    CreatedBy   = data.aws_caller_identity.current.user_id
    Region      = data.aws_region.current.name
  })
}