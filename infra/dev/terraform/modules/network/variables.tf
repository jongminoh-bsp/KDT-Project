variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_mgmt_subnet_cidrs" {
  type = list(string)
}

variable "private_ng_subnet_cidrs" {
  type = list(string)
}

variable "private_rds_subnet_cidrs" {
  type = list(string)
}

variable "private_qdev_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
  description = "Availability zones"
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

