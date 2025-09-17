module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_security_group_id = var.cluster_sg_id
  node_security_group_id    = var.node_sg_id

  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    ojm-node = {
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      subnet_ids     = var.subnet_ids
    }
  }

  tags = var.tags
}

