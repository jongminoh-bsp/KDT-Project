# Management Security Group
resource "aws_security_group" "mgmt" {
  name        = "${var.name_prefix}-management-sg"
  description = "Security group for management instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-management-sg"
    Purpose = "management"
  })
}

# EKS NodeGroup Security Group
resource "aws_security_group" "ng" {
  name        = "${var.name_prefix}-nodegroup-sg"
  description = "Security group for EKS node group"
  vpc_id      = var.vpc_id

  # Allow communication within the node group
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-nodegroup-sg"
    Purpose = "eks-nodegroup"
  })
}

# EKS Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "${var.name_prefix}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-cluster-sg"
    Purpose = "eks-cluster"
  })
}

# Security Group Rules (separate resources to avoid circular dependency)
resource "aws_security_group_rule" "ng_from_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.ng.id
  description              = "Allow EKS Control Plane to Node"
}

resource "aws_security_group_rule" "ng_https_from_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.ng.id
  description              = "Allow HTTPS from control plane"
}

resource "aws_security_group_rule" "cluster_from_ng" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ng.id
  security_group_id        = aws_security_group.cluster.id
  description              = "Allow HTTPS from NodeGroup"
}

resource "aws_security_group_rule" "cluster_from_mgmt" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mgmt.id
  security_group_id        = aws_security_group.cluster.id
  description              = "Allow HTTPS from Management"
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-database-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ng.id]
    description     = "Allow MySQL from NodeGroup"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-database-sg"
    Purpose = "database"
  })
}

# Q-Dev Security Group
resource "aws_security_group" "qdev" {
  name        = "${var.name_prefix}-qdev-sg"
  description = "Security group for Q Developer instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for SSM access"
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-qdev-sg"
    Purpose = "development"
  })
}
