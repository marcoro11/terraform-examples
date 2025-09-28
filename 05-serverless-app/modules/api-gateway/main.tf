data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.app_name}-api-${var.stage}"
  description = "REST API for ${var.app_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.auth_register,
    aws_api_gateway_integration.auth_login,
    aws_api_gateway_integration.auth_refresh,
    aws_api_gateway_integration.auth_logout,
    aws_api_gateway_integration.users_list,
    aws_api_gateway_integration.users_get,
    aws_api_gateway_integration.users_create,
    aws_api_gateway_integration.users_update,
    aws_api_gateway_integration.users_delete,
    aws_api_gateway_integration.files_list,
    aws_api_gateway_integration.files_upload,
    aws_api_gateway_integration.files_download,
    aws_api_gateway_integration.files_delete,
    aws_api_gateway_integration.health
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.stage

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      caller        = "$context.identity.caller"
      user          = "$context.identity.user"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      resourcePath  = "$context.resourcePath"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/${var.app_name}-${var.stage}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.app_name}-cognito-authorizer-${var.stage}"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  provider_arns = [var.cognito_user_pool_arn]
}

resource "aws_api_gateway_usage_plan" "main" {
  name        = "${var.app_name}-usage-plan-${var.stage}"
  description = "Usage plan for ${var.app_name} API"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  quota_settings {
    limit  = 10000
    offset = 0
    period = "DAY"
  }

  tags = var.tags
}

resource "aws_api_gateway_api_key" "main" {
  count = var.enable_api_key ? 1 : 0

  name        = "${var.app_name}-api-key-${var.stage}"
  description = "API key for ${var.app_name}"
  enabled     = true

  tags = var.tags
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count = var.enable_api_key ? 1 : 0

  key_id        = aws_api_gateway_api_key.main[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

resource "aws_api_gateway_method" "cors_root" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.cors_root.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "cors_root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.cors_root.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allowed_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "cors_root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.cors_root.http_method
  status_code = aws_api_gateway_method_response.cors_root.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allowed_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "auth_register" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "register"
}

resource "aws_api_gateway_method" "auth_register" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_register.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_register" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_register.id
  http_method             = aws_api_gateway_method.auth_register.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.auth_register
}

resource "aws_api_gateway_method_response" "auth_register" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_register.id
  http_method = aws_api_gateway_method.auth_register.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "auth_register" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_register.id
  http_method = aws_api_gateway_method.auth_register.http_method
  status_code = aws_api_gateway_method_response.auth_register.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "auth_login" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "login"
}

resource "aws_api_gateway_method" "auth_login" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_login" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_login.id
  http_method             = aws_api_gateway_method.auth_login.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.auth_login
}

resource "aws_api_gateway_method_response" "auth_login" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_login.id
  http_method = aws_api_gateway_method.auth_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "auth_login" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_login.id
  http_method = aws_api_gateway_method.auth_login.http_method
  status_code = aws_api_gateway_method_response.auth_login.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "auth_refresh" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "refresh"
}

resource "aws_api_gateway_method" "auth_refresh" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_refresh.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "auth_refresh" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_refresh.id
  http_method             = aws_api_gateway_method.auth_refresh.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.auth_refresh
}

resource "aws_api_gateway_method_response" "auth_refresh" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_refresh.id
  http_method = aws_api_gateway_method.auth_refresh.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "auth_refresh" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_refresh.id
  http_method = aws_api_gateway_method.auth_refresh.http_method
  status_code = aws_api_gateway_method_response.auth_refresh.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "auth_logout" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "logout"
}

resource "aws_api_gateway_method" "auth_logout" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.auth_logout.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "auth_logout" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.auth_logout.id
  http_method             = aws_api_gateway_method.auth_logout.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.auth_logout
}

resource "aws_api_gateway_method_response" "auth_logout" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_logout.id
  http_method = aws_api_gateway_method.auth_logout.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "auth_logout" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.auth_logout.id
  http_method = aws_api_gateway_method.auth_logout.http_method
  status_code = aws_api_gateway_method_response.auth_logout.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "users_list" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "users_list" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users_list.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.users_list
}

resource "aws_api_gateway_method_response" "users_list" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_list.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "users_list" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_list.http_method
  status_code = aws_api_gateway_method_response.users_list.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "users_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "users_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users_id.id
  http_method             = aws_api_gateway_method.users_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.users_get
}

resource "aws_api_gateway_method_response" "users_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users_id.id
  http_method = aws_api_gateway_method.users_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "users_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users_id.id
  http_method = aws_api_gateway_method.users_get.http_method
  status_code = aws_api_gateway_method_response.users_get.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_method" "users_create" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "users_create" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users_create.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.users_create
}

resource "aws_api_gateway_method_response" "users_create" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_create.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "users_create" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_create.http_method
  status_code = aws_api_gateway_method_response.users_create.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_method" "users_update" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users_id.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "users_update" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users_id.id
  http_method             = aws_api_gateway_method.users_update.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.users_update
}

resource "aws_api_gateway_method_response" "users_update" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users_id.id
  http_method = aws_api_gateway_method.users_update.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "users_update" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users_id.id
  http_method = aws_api_gateway_method.users_update.http_method
  status_code = aws_api_gateway_method_response.users_update.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_method" "users_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "users_delete" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.users_id.id
  http_method             = aws_api_gateway_method.users_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.users_delete
}

resource "aws_api_gateway_method_response" "users_delete" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users_id.id
  http_method = aws_api_gateway_method.users_delete.http_method
  status_code = "204"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "users_delete" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users_id.id
  http_method = aws_api_gateway_method.users_delete.http_method
  status_code = aws_api_gateway_method_response.users_delete.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_method" "files_list" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "files_list" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.files.id
  http_method             = aws_api_gateway_method.files_list.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.files_list
}

resource "aws_api_gateway_method_response" "files_list" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.files_list.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "files_list" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.files_list.http_method
  status_code = aws_api_gateway_method_response.files_list.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "files_upload" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.files.id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "files_upload" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.files_upload.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "files_upload" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.files_upload.id
  http_method             = aws_api_gateway_method.files_upload.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.files_upload
}

resource "aws_api_gateway_method_response" "files_upload" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files_upload.id
  http_method = aws_api_gateway_method.files_upload.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "files_upload" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files_upload.id
  http_method = aws_api_gateway_method.files_upload.http_method
  status_code = aws_api_gateway_method_response.files_upload.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "files_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.files.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "files_download" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.files_id.id
  path_part   = "download"
}

resource "aws_api_gateway_method" "files_download" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.files_download.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "files_download" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.files_download.id
  http_method             = aws_api_gateway_method.files_download.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.files_download
}

resource "aws_api_gateway_method_response" "files_download" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files_download.id
  http_method = aws_api_gateway_method.files_download.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "files_download" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files_download.id
  http_method = aws_api_gateway_method.files_download.http_method
  status_code = aws_api_gateway_method_response.files_download.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_method" "files_delete" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.files_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "files_delete" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.files_id.id
  http_method             = aws_api_gateway_method.files_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.files_delete
}

resource "aws_api_gateway_method_response" "files_delete" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files_id.id
  http_method = aws_api_gateway_method.files_delete.http_method
  status_code = "204"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "files_delete" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.files_id.id
  http_method = aws_api_gateway_method.files_delete.http_method
  status_code = aws_api_gateway_method_response.files_delete.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_functions.health
}

resource "aws_api_gateway_method_response" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_api_gateway_integration_response" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health.http_method
  status_code = aws_api_gateway_method_response.health.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${join(",", var.cors_allowed_origins)}'"
  }
}

resource "aws_lambda_permission" "auth_register" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.auth_register
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "auth_login" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.auth_login
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "auth_refresh" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.auth_refresh
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "auth_logout" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.auth_logout
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "users_list" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.users_list
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "users_get" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.users_get
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "users_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.users_create
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "users_update" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.users_update
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "users_delete" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.users_delete
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "files_list" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.files_list
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "files_upload" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.files_upload
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "files_download" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.files_download
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "files_delete" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.files_delete
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "health" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names.health
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_api_gateway_domain_name" "main" {
  count = var.domain_name != "" ? 1 : 0

  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_base_path_mapping" "main" {
  count = var.domain_name != "" ? 1 : 0

  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
}