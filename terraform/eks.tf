module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = aws_vpc.ojm.id
  subnet_ids = [aws_subnet.private-ng[0].id, aws_subnet.private-ng[1].id]

  cluster_security_group_id = aws_security_group.cluster-sg.id
  node_security_group_id    = aws_security_group.ng-sg.id

  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    ojm-node = {
      instance_types = ["t3.medium"]
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      subnet_ids = [
        aws_subnet.private-ng[0].id,
        aws_subnet.private-ng[1].id
      ]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
