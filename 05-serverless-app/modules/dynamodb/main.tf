resource "aws_dynamodb_table" "users" {
  name           = "${var.app_name}-users-${var.stage}"
  billing_mode   = var.billing_mode
  hash_key       = "user_id"
  
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.users_table_config.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.users_table_config.write_capacity : null

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  global_secondary_index {
    name            = "email-index"
    hash_key        = "email"
    projection_type = "ALL"
    
    read_capacity  = var.billing_mode == "PROVISIONED" ? var.users_table_config.read_capacity : null
    write_capacity = var.billing_mode == "PROVISIONED" ? var.users_table_config.write_capacity : null
  }

  global_secondary_index {
    name            = "created-at-index"
    hash_key        = "created_at"
    projection_type = "KEYS_ONLY"
    
    read_capacity  = var.billing_mode == "PROVISIONED" ? 5 : null
    write_capacity = var.billing_mode == "PROVISIONED" ? 5 : null
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = var.stage == "prod"

  tags = merge(var.tags, {
    Name = "${var.app_name}-users-${var.stage}"
    Type = "DynamoDB Table"
  })
}

resource "aws_dynamodb_table" "files" {
  name           = "${var.app_name}-files-${var.stage}"
  billing_mode   = var.billing_mode
  hash_key       = "file_id"

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.files_table_config.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.files_table_config.write_capacity : null

  attribute {
    name = "file_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  global_secondary_index {
    name            = "user-files-index"
    hash_key        = "user_id"
    range_key       = "created_at"
    projection_type = "ALL"
    
    read_capacity  = var.billing_mode == "PROVISIONED" ? var.files_table_config.read_capacity : null
    write_capacity = var.billing_mode == "PROVISIONED" ? var.files_table_config.write_capacity : null
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = var.stage == "prod"

  tags = merge(var.tags, {
    Name = "${var.app_name}-files-${var.stage}"
    Type = "DynamoDB Table"
  })
}

resource "aws_dynamodb_table" "sessions" {
  name           = "${var.app_name}-sessions-${var.stage}"
  billing_mode   = var.billing_mode
  hash_key       = "session_id"

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.sessions_table_config.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.sessions_table_config.write_capacity : null

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "expires_at"
    type = "N"
  }

  global_secondary_index {
    name            = "user-sessions-index"
    hash_key        = "user_id"
    projection_type = "ALL"
    
    read_capacity  = var.billing_mode == "PROVISIONED" ? 5 : null
    write_capacity = var.billing_mode == "PROVISIONED" ? 5 : null
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = var.stage == "prod"

  tags = merge(var.tags, {
    Name = "${var.app_name}-sessions-${var.stage}"
    Type = "DynamoDB Table"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.create_vpc_endpoint ? 1 : 0
  
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  
  tags = merge(var.tags, {
    Name = "${var.app_name}-dynamodb-endpoint-${var.stage}"
  })
}

data "aws_region" "current" {}