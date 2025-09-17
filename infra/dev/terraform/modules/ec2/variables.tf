variable "ami_id" {
  type = string
}

variable "mgmt_instance_type" {
  type = string
}

variable "q_dev_instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "mgmt_subnet_id" {
  type = string
}

variable "q_dev_subnet_id" {
  type = string
}

variable "mgmt_sg_ids" {
  type = list(string)
}

variable "q_dev_sg_ids" {
  type = list(string)
}

