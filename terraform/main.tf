terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "skyline-system"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  cluster_name = "skyline-dev-eks"
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)
  
  tags = {
    Project     = "skyline-system"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
