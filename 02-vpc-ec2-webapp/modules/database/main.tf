resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"

  multi_az               = true
  publicly_accessible    = false
  vpc_security_group_ids = [var.database_security_group_id]
  db_subnet_group_name   = var.database_subnet_group_name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade = true
  deletion_protection        = false

  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-${var.environment}-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  parameter_group_name = "default.redis8.0"
  engine_version       = "8.0"
  port                 = 6379

  subnet_group_name  = var.redis_subnet_group_name
  security_group_ids = [var.redis_security_group_id]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis"
  })
}