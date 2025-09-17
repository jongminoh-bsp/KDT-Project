# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# Management EC2
resource "aws_instance" "mgmt" {
  ami                         = var.ami_id
  instance_type               = var.mgmt_instance_type
  subnet_id                   = var.mgmt_subnet_id
  vpc_security_group_ids      = var.mgmt_sg_ids
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "ojm-mgmt"
  }
}

# Q-Dev EC2
resource "aws_instance" "q_dev" {
  ami                         = var.ami_id
  instance_type               = var.q_dev_instance_type
  subnet_id                   = var.q_dev_subnet_id
  vpc_security_group_ids      = var.q_dev_sg_ids
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "ojm-q-dev"
  }
}

