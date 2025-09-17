resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
    Type = "public"
    AZ   = var.azs[count.index]
  })
}

# Private Management Subnets
resource "aws_subnet" "private_mgmt" {
  count             = length(var.private_mgmt_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_mgmt_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-mgmt-subnet-${count.index + 1}"
    Type    = "private"
    Purpose = "management"
    AZ      = var.azs[count.index]
  })
}

# Private NodeGroup Subnets
resource "aws_subnet" "private_ng" {
  count             = length(var.private_ng_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_ng_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-nodegroup-subnet-${count.index + 1}"
    Type    = "private"
    Purpose = "nodegroup"
    AZ      = var.azs[count.index]
  })
}

# Private RDS Subnets
resource "aws_subnet" "private_rds" {
  count             = length(var.private_rds_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_rds_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-rds-subnet-${count.index + 1}"
    Type    = "private"
    Purpose = "database"
    AZ      = var.azs[count.index]
  })
}

# Private Q-Dev Subnets
resource "aws_subnet" "private_qdev" {
  count             = length(var.private_qdev_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_qdev_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-qdev-subnet-${count.index + 1}"
    Type    = "private"
    Purpose = "development"
    AZ      = var.azs[count.index]
  })
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-internet-gateway"
  })
}

# NAT Gateway EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-gateway"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-route-table"
    Type = "public"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Management Route Table
resource "aws_route_table" "private_mgmt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-mgmt-route-table"
    Type    = "private"
    Purpose = "management"
  })
}

resource "aws_route_table_association" "private_mgmt" {
  count          = length(aws_subnet.private_mgmt)
  subnet_id      = aws_subnet.private_mgmt[count.index].id
  route_table_id = aws_route_table.private_mgmt.id
}

# Private NodeGroup Route Table
resource "aws_route_table" "private_ng" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-nodegroup-route-table"
    Type    = "private"
    Purpose = "nodegroup"
  })
}

resource "aws_route_table_association" "private_ng" {
  count          = length(aws_subnet.private_ng)
  subnet_id      = aws_subnet.private_ng[count.index].id
  route_table_id = aws_route_table.private_ng.id
}

# Private RDS Route Table
resource "aws_route_table" "private_rds" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-rds-route-table"
    Type    = "private"
    Purpose = "database"
  })
}

resource "aws_route_table_association" "private_rds" {
  count          = length(aws_subnet.private_rds)
  subnet_id      = aws_subnet.private_rds[count.index].id
  route_table_id = aws_route_table.private_rds.id
}

# Private Q-Dev Route Table
resource "aws_route_table" "private_qdev" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-private-qdev-route-table"
    Type    = "private"
    Purpose = "development"
  })
}

resource "aws_route_table_association" "private_qdev" {
  count          = length(aws_subnet.private_qdev)
  subnet_id      = aws_subnet.private_qdev[count.index].id
  route_table_id = aws_route_table.private_qdev.id
}
