# Secrets Manager for RDS password
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "${var.name_prefix}-rds-password-${formatdate("YYYYMMDD-hhmm", timestamp())}"
  description = "RDS password for ${var.name_prefix}"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rds-password"
  })
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds_password.result
  })
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rds-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier        = "${var.name_prefix}-database"
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.rds_password.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.sg_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-database"
  })
}
