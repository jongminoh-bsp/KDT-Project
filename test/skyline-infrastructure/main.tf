# Skyline Infrastructure - Test PR Automation
# This configuration deploys AWS infrastructure for Skyline application

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "kdt-project-terraform-state"
    key    = "skyline/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  
  tags = var.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_max_size       = var.eks_node_max_size
  node_min_size       = var.eks_node_min_size
  
  tags = var.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  db_instance_class = var.rds_instance_class
  db_name          = var.rds_db_name
  db_username      = var.rds_username
  
  tags = var.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
  
  tags = var.common_tags
}
