output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_mgmt_subnets" {
  value = aws_subnet.private_mgmt[*].id
}

output "private_ng_subnets" {
  value = aws_subnet.private_ng[*].id
}

output "private_rds_subnets" {
  value = aws_subnet.private_rds[*].id
}

output "private_qdev_subnets" {
  value = aws_subnet.private_qdev[*].id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

