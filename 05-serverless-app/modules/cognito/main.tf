resource "aws_cognito_user_pool" "main" {
  name = "${var.app_name}-users-${var.stage}"

  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_lowercase = var.password_policy.require_lowercase
    require_uppercase = var.password_policy.require_uppercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
  }

  mfa_configuration = var.enable_mfa ? "OPTIONAL" : "OFF"

  auto_verified_attributes = var.enable_email_login ? ["email"] : []

  username_configuration {
    case_sensitive = false
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = var.enable_email_login

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "name"
    required            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  dynamic "lambda_config" {
    for_each = var.enable_lambda_triggers ? [1] : []
    content {
      pre_sign_up = var.pre_signup_lambda_arn
    }
  }

  tags = merge(var.tags, {
    Name = "${var.app_name}-user-pool-${var.stage}"
  })
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.app_name}-client-${var.stage}"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  access_token_validity  = 1   # hours
  id_token_validity     = 1   # hours
  refresh_token_validity = 30  # days

  supported_identity_providers = ["COGNITO"]
  allowed_oauth_flows          = ["code"]
  allowed_oauth_scopes         = ["openid", "email", "profile"]
  callback_urls                = var.frontend_callback_urls
  logout_urls                  = var.frontend_callback_urls

  prevent_user_existence_errors = "ENABLED"

  enable_token_revocation = true
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.app_name}-${var.stage}"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_identity_pool" "main" {
  count = var.enable_identity_pool ? 1 : 0

  identity_pool_name               = "${var.app_name}_identity_pool_${var.stage}"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.main.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  tags = merge(var.tags, {
    Name = "${var.app_name}-identity-pool-${var.stage}"
  })
}

resource "aws_iam_role" "authenticated" {
  count = var.enable_identity_pool ? 1 : 0

  name = "${var.app_name}-authenticated-${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "authenticated" {
  count = var.enable_identity_pool ? 1 : 0

  name = "${var.app_name}-authenticated-policy-${var.stage}"
  role = aws_iam_role.authenticated[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count = var.enable_identity_pool ? 1 : 0

  identity_pool_id = aws_cognito_identity_pool.main[0].id

  roles = {
    authenticated = aws_iam_role.authenticated[0].arn
  }
}