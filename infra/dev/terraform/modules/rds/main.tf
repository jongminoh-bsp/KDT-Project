# Secrets Manager for RDS password
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "${var.db_identifier}-password"
  description = "RDS password for ${var.db_identifier}"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
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
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.db_identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  username               = var.db_username
  password               = random_password.rds_password.result
  db_name                = var.db_name
  skip_final_snapshot    = true
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  vpc_security_group_ids = var.sg_ids
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = {
    Name = var.db_identifier
  }
}

