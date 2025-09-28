resource "aws_iam_role" "lambda" {
  name = "${var.app_name}-lambda-${var.stage}"

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

resource "aws_iam_role_policy" "lambda" {
  name = "${var.app_name}-lambda-policy-${var.stage}"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminDeleteUser"
        ]
        Resource = [var.cognito_user_pool_arn]
      }
    ]
  })
}

resource "aws_lambda_layer_version" "common" {
  filename   = data.archive_file.layer_zip.output_path
  layer_name = "${var.app_name}-common-layer-${var.stage}"

  compatible_runtimes = [var.runtime]
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256

  depends_on = [data.archive_file.layer_zip]
}

data "archive_file" "layer_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-layer-${var.stage}.zip"

  source {
    content  = "layer"
    filename = "dummy.txt"
  }
}

resource "aws_lambda_function" "auth_register" {
  filename         = data.archive_file.auth_register_zip.output_path
  function_name    = "${var.app_name}-auth-register-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.auth_register_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-auth-register-${var.stage}"
  })

  depends_on = [data.archive_file.auth_register_zip]
}

resource "aws_lambda_function" "auth_login" {
  filename         = data.archive_file.auth_login_zip.output_path
  function_name    = "${var.app_name}-auth-login-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.auth_login_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-auth-login-${var.stage}"
  })

  depends_on = [data.archive_file.auth_login_zip]
}

resource "aws_lambda_function" "auth_refresh" {
  filename         = data.archive_file.auth_refresh_zip.output_path
  function_name    = "${var.app_name}-auth-refresh-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.auth_refresh_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-auth-refresh-${var.stage}"
  })

  depends_on = [data.archive_file.auth_refresh_zip]
}

resource "aws_lambda_function" "auth_logout" {
  filename         = data.archive_file.auth_logout_zip.output_path
  function_name    = "${var.app_name}-auth-logout-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.auth_logout_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-auth-logout-${var.stage}"
  })

  depends_on = [data.archive_file.auth_logout_zip]
}

resource "aws_lambda_function" "users_list" {
  filename         = data.archive_file.users_list_zip.output_path
  function_name    = "${var.app_name}-users-list-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.users_list_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-users-list-${var.stage}"
  })

  depends_on = [data.archive_file.users_list_zip]
}

resource "aws_lambda_function" "users_get" {
  filename         = data.archive_file.users_get_zip.output_path
  function_name    = "${var.app_name}-users-get-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.users_get_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-users-get-${var.stage}"
  })

  depends_on = [data.archive_file.users_get_zip]
}

resource "aws_lambda_function" "users_create" {
  filename         = data.archive_file.users_create_zip.output_path
  function_name    = "${var.app_name}-users-create-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.users_create_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-users-create-${var.stage}"
  })

  depends_on = [data.archive_file.users_create_zip]
}

resource "aws_lambda_function" "users_update" {
  filename         = data.archive_file.users_update_zip.output_path
  function_name    = "${var.app_name}-users-update-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.users_update_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-users-update-${var.stage}"
  })

  depends_on = [data.archive_file.users_update_zip]
}

resource "aws_lambda_function" "users_delete" {
  filename         = data.archive_file.users_delete_zip.output_path
  function_name    = "${var.app_name}-users-delete-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.users_delete_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-users-delete-${var.stage}"
  })

  depends_on = [data.archive_file.users_delete_zip]
}

resource "aws_lambda_function" "files_list" {
  filename         = data.archive_file.files_list_zip.output_path
  function_name    = "${var.app_name}-files-list-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.files_list_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-files-list-${var.stage}"
  })

  depends_on = [data.archive_file.files_list_zip]
}

resource "aws_lambda_function" "files_upload" {
  filename         = data.archive_file.files_upload_zip.output_path
  function_name    = "${var.app_name}-files-upload-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.files_upload_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-files-upload-${var.stage}"
  })

  depends_on = [data.archive_file.files_upload_zip]
}

resource "aws_lambda_function" "files_download" {
  filename         = data.archive_file.files_download_zip.output_path
  function_name    = "${var.app_name}-files-download-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.files_download_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-files-download-${var.stage}"
  })

  depends_on = [data.archive_file.files_download_zip]
}

resource "aws_lambda_function" "files_delete" {
  filename         = data.archive_file.files_delete_zip.output_path
  function_name    = "${var.app_name}-files-delete-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.files_delete_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-files-delete-${var.stage}"
  })

  depends_on = [data.archive_file.files_delete_zip]
}

resource "aws_lambda_function" "health" {
  filename         = data.archive_file.health_zip.output_path
  function_name    = "${var.app_name}-health-${var.stage}"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  runtime         = var.runtime
  timeout         = 10
  memory_size     = 128

  environment {
    variables = var.environment_variables
  }

  layers = [aws_lambda_layer_version.common.arn]

  source_code_hash = data.archive_file.health_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${var.app_name}-health-${var.stage}"
  })

  depends_on = [data.archive_file.health_zip]
}

data "archive_file" "auth_register_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-auth-register-${var.stage}.zip"

  source {
    content  = "# Auth register function code"
    filename = "index.py"
  }
}

data "archive_file" "auth_login_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-auth-login-${var.stage}.zip"

  source {
    content  = "# Auth login function code"
    filename = "index.py"
  }
}

data "archive_file" "auth_refresh_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-auth-refresh-${var.stage}.zip"

  source {
    content  = "# Auth refresh function code"
    filename = "index.py"
  }
}

data "archive_file" "auth_logout_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-auth-logout-${var.stage}.zip"

  source {
    content  = "# Auth logout function code"
    filename = "index.py"
  }
}

data "archive_file" "users_list_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-users-list-${var.stage}.zip"

  source {
    content  = "# Users list function code"
    filename = "index.py"
  }
}

data "archive_file" "users_get_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-users-get-${var.stage}.zip"

  source {
    content  = "# Users get function code"
    filename = "index.py"
  }
}

data "archive_file" "users_create_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-users-create-${var.stage}.zip"

  source {
    content  = "# Users create function code"
    filename = "index.py"
  }
}

data "archive_file" "users_update_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-users-update-${var.stage}.zip"

  source {
    content  = "# Users update function code"
    filename = "index.py"
  }
}

data "archive_file" "users_delete_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-users-delete-${var.stage}.zip"

  source {
    content  = "# Users delete function code"
    filename = "index.py"
  }
}

data "archive_file" "files_list_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-files-list-${var.stage}.zip"

  source {
    content  = "# Files list function code"
    filename = "index.py"
  }
}

data "archive_file" "files_upload_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-files-upload-${var.stage}.zip"

  source {
    content  = "# Files upload function code"
    filename = "index.py"
  }
}

data "archive_file" "files_download_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-files-download-${var.stage}.zip"

  source {
    content  = "# Files download function code"
    filename = "index.py"
  }
}

data "archive_file" "files_delete_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-files-delete-${var.stage}.zip"

  source {
    content  = "# Files delete function code"
    filename = "index.py"
  }
}

data "archive_file" "health_zip" {
  type        = "zip"
  output_path = "/tmp/${var.app_name}-health-${var.stage}.zip"

  source {
    content  = "# Health check function code"
    filename = "index.py"
  }
}