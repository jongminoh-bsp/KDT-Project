output "mgmt_sg_id" {
  value = aws_security_group.mgmt.id
}

output "ng_sg_id" {
  value = aws_security_group.ng.id
}

output "cluster_sg_id" {
  value = aws_security_group.cluster.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "qdev_sg_id" {
  value = aws_security_group.qdev.id
}

