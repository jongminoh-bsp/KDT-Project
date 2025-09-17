variable "subnet_ids" {
  type = list(string)
  description = "Private RDS subnet IDs"
}

variable "sg_ids" {
  type = list(string)
  description = "RDS Security Group IDs"
}

variable "db_identifier" {
  type    = string
  default = "ojm-rds"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "engine_version" {
  type    = string
  default = "8.0.41"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "db_username" {
  type = string
}

variable "db_name" {
  type = string
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "multi_az" {
  type    = bool
  default = false
}

