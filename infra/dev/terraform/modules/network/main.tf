resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ojm-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-snt-${substr(var.azs[count.index], -1, 1)}"
  }
}

# Private Subnets
resource "aws_subnet" "private_mgmt" {
  count             = length(var.private_mgmt_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_mgmt_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-mgmt-snt-${substr(var.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private_ng" {
  count             = length(var.private_ng_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_ng_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-ng-snt-${substr(var.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private_rds" {
  count             = length(var.private_rds_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_rds_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-rds-snt-${substr(var.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private_qdev" {
  count             = length(var.private_qdev_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_qdev_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-qdev-snt"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "ojm-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "ojm-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ojm-nat-gw"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "public-rtb" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_mgmt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = { Name = "private-mgmt-rtb" }
}

resource "aws_route_table_association" "private_mgmt" {
  count          = length(aws_subnet.private_mgmt)
  subnet_id      = aws_subnet.private_mgmt[count.index].id
  route_table_id = aws_route_table.private_mgmt.id
}

resource "aws_route_table" "private_ng" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = { Name = "private-ng-rtb" }
}

resource "aws_route_table_association" "private_ng" {
  count          = length(aws_subnet.private_ng)
  subnet_id      = aws_subnet.private_ng[count.index].id
  route_table_id = aws_route_table.private_ng.id
}

resource "aws_route_table" "private_rds" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "private-rds-rtb" }
}

resource "aws_route_table_association" "private_rds" {
  count          = length(aws_subnet.private_rds)
  subnet_id      = aws_subnet.private_rds[count.index].id
  route_table_id = aws_route_table.private_rds.id
}

resource "aws_route_table" "private_qdev" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = { Name = "private-qdev-rtb" }
}

resource "aws_route_table_association" "private_qdev" {
  count          = length(aws_subnet.private_qdev)
  subnet_id      = aws_subnet.private_qdev[count.index].id
  route_table_id = aws_route_table.private_qdev.id
}

