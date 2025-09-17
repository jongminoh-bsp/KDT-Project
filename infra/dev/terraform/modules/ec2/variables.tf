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

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default     = {}
}

