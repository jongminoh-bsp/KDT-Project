variable "region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "kdt"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.30.10.0/24", "10.30.20.0/24"]
}

variable "private_mgmt_subnet_cidrs" {
  default = ["10.30.11.0/24", "10.30.21.0/24"]
}

variable "private_ng_subnet_cidrs" {
  default = ["10.30.12.0/23", "10.30.22.0/23"]
}

variable "private_rds_subnet_cidrs" {
  default = ["10.30.14.0/24", "10.30.24.0/24"]
}

variable "private_qdev_subnet_cidrs" {
  default = ["10.30.15.0/24", "10.30.25.0/24"]
}

variable "key_name" {
  description = "Key Pair"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "mgmt_instance_type" {
  description = "The instance type of mgmt server"
  type        = string
}

variable "q_dev_instance_type" {
  description = "The instance type of qdev server"
  type        = string
}

variable "db_username" {
  description = "The master username for RDS"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "node_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0.41"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}
