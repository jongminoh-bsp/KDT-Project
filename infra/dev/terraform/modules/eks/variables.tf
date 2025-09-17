variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
  default = "1.28"
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_sg_id" {
  type = string
}

variable "node_sg_id" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
  default = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}

