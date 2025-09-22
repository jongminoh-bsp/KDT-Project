# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "skyline-dev-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(local.tags, {
    Name = "skyline-dev-db-subnet-group"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "mysql8.0"
  name   = "skyline-dev-mysql-params"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = local.tags
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "skyline-dev-mysql"

  # Engine
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = var.rds_instance_class

  # Storage
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database
  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # High Availability
  multi_az               = true
  availability_zone      = null # Let AWS choose for Multi-AZ

  # Backup & Maintenance
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  delete_automated_backups = true

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query"]

  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.main.name

  # Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true

  # Apply changes immediately (for dev environment)
  apply_immediately = true

  tags = merge(local.tags, {
    Name = "skyline-dev-mysql"
  })
}

# RDS Monitoring IAM Role
resource "aws_iam_role" "rds_monitoring" {
  name = "skyline-dev-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
