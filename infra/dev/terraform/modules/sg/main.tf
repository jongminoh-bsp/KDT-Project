# Management SG
resource "aws_security_group" "mgmt" {
  name        = "mgmt-sg"
  description = "Mgmt SSH from Bastion"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mgmt-sg"
  }
}

# NodeGroup SG
resource "aws_security_group" "ng" {
  name        = "ng-sg"
  description = "EKS NodeGroup SG"
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

  tags = {
    Name = "ng-sg"
  }
}

# Cluster SG
resource "aws_security_group" "cluster" {
  name        = "cluster-sg"
  description = "EKS cluster SG"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster-sg"
  }
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

# RDS SG
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow MySQL from NodeGroup"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ng.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Q-Dev SG
resource "aws_security_group" "qdev" {
  name        = "q-dev-sg"
  description = "Security group for Q Developer EC2 (SSM access)"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "q-dev-sg"
  }
}
