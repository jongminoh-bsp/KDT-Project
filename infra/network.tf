resource "aws_vpc" "ojm" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ojm-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.ojm.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-snt-${substr(local.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private-mgmt" {
  count             = length(var.private_mgmt_subnet_cidrs)
  vpc_id            = aws_vpc.ojm.id
  cidr_block        = var.private_mgmt_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name = "private-mgmt-snt-${substr(local.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private-ng" {
  count             = length(var.private_ng_subnet_cidrs)
  vpc_id            = aws_vpc.ojm.id
  cidr_block        = var.private_ng_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "private-ng-snt-${substr(local.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private-rds" {
  count             = length(var.private_rds_subnet_cidrs)
  vpc_id            = aws_vpc.ojm.id
  cidr_block        = var.private_rds_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "private-rds-snt-${substr(local.azs[count.index], -1, 1)}"
  }
}

resource "aws_subnet" "private-qdev" {
  count             = length(var.private_qdev_subnet_cidrs)
  vpc_id            = aws_vpc.ojm.id
  cidr_block        = var.private_qdev_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "private-qdev-snt"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ojm.id

  tags = {
    Name = "ojm-igw"
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"

  tags = {
    Name = "ojm-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ojm-nat-gw"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.ojm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table" "private-mgmt-rtb" {
  vpc_id = aws_vpc.ojm.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-mgmt-rtb"
  }
}

resource "aws_route_table_association" "private-mgmt-as" {
  count          = length(aws_subnet.private-mgmt)
  subnet_id      = aws_subnet.private-mgmt[count.index].id
  route_table_id = aws_route_table.private-mgmt-rtb.id
}

resource "aws_route_table" "private-ng-rtb" {
  vpc_id = aws_vpc.ojm.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-ng-rtb"
  }
}

resource "aws_route_table_association" "private-ng-as" {
  count          = length(aws_subnet.private-ng)
  subnet_id      = aws_subnet.private-ng[count.index].id
  route_table_id = aws_route_table.private-ng-rtb.id
}

resource "aws_route_table" "private-rds-rtb" {
  vpc_id = aws_vpc.ojm.id

  tags = {
    Name = "private-rds-rtb"
  }
}

resource "aws_route_table_association" "private-rds-as" {
  count          = length(aws_subnet.private-rds)
  subnet_id      = aws_subnet.private-rds[count.index].id
  route_table_id = aws_route_table.private-rds-rtb.id
}

resource "aws_route_table" "private-qdev-rtb" {
  vpc_id = aws_vpc.ojm.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-qdev-rtb"
  }
}

resource "aws_route_table_association" "private-qdev-as" {
  count          = length(aws_subnet.private-qdev)
  subnet_id      = aws_subnet.private-qdev[count.index].id
  route_table_id = aws_route_table.private-qdev-rtb.id
}
