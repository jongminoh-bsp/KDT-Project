output "mgmt_instance_id" {
  value = aws_instance.mgmt.id
}

output "mgmt_instance_public_ip" {
  value = aws_instance.mgmt.public_ip
}

output "q_dev_instance_id" {
  value = aws_instance.q_dev.id
}

output "q_dev_instance_public_ip" {
  value = aws_instance.q_dev.public_ip
}

