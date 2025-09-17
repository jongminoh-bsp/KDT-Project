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

resource "aws_instance" "mgmt" {
  ami                         = var.ami_id
  instance_type               = var.mgmt_instance_type
  subnet_id                   = aws_subnet.private-mgmt[0].id
  vpc_security_group_ids      = [aws_security_group.mgmt-sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "ojm-mgmt"
  }
}

resource "aws_instance" "q-dev" {
  ami                         = var.ami_id
  instance_type               = var.q_dev_instance_type
  subnet_id                   = aws_subnet.private-qdev[0].id
  vpc_security_group_ids      = [aws_security_group.q_dev-sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "ojm-q-dev"
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm_role.name
}
