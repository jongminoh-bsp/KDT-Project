#################################################
# Module: Network
#################################################
module "network" {
  source = "./modules/network"

  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_mgmt_subnet_cidrs = var.private_mgmt_subnet_cidrs
  private_ng_subnet_cidrs   = var.private_ng_subnet_cidrs
  private_rds_subnet_cidrs  = var.private_rds_subnet_cidrs
  private_qdev_subnet_cidrs = var.private_qdev_subnet_cidrs
  azs                       = local.azs
  
  name_prefix  = local.name_prefix
  common_tags  = local.common_tags
}

#################################################
# Module: Security Groups
#################################################
module "sg" {
  source = "./modules/sg"
  
  vpc_id      = module.network.vpc_id
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

#################################################
# Module: RDS
#################################################
module "rds" {
  source     = "./modules/rds"
  subnet_ids = module.network.private_rds_subnets
  sg_ids     = [module.sg.rds_sg_id]

  db_username = var.db_username
  db_name     = var.db_name
}

#################################################
# Module: EC2 (Mgmt + Q-Dev)
#################################################
module "ec2" {
  source = "./modules/ec2"

  ami_id              = var.ami_id
  mgmt_instance_type  = var.mgmt_instance_type
  q_dev_instance_type = var.q_dev_instance_type
  key_name            = var.key_name

  mgmt_subnet_id = module.network.private_mgmt_subnets[0]
  q_dev_subnet_id = module.network.private_qdev_subnets[0]

  mgmt_sg_ids = [module.sg.mgmt_sg_id]
  q_dev_sg_ids = [module.sg.qdev_sg_id]
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

#################################################
# Module: EKS
#################################################
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id   = module.network.vpc_id
  subnet_ids = module.network.private_ng_subnets

  cluster_sg_id = module.sg.cluster_sg_id
  node_sg_id    = module.sg.ng_sg_id

  node_instance_types = ["t3.medium"]
  node_desired_size   = 1
  node_min_size       = 1
  node_max_size       = 2

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

