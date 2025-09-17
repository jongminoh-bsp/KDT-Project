region = "ap-northeast-2"

project     = "kdt"
environment = "dev"

# EC2 Key Pair (consider using AWS Systems Manager Session Manager instead)
key_name = "ojm-key"

ami_id = "ami-0d5bb3742db8fc264"

mgmt_instance_type  = "t3.medium"
q_dev_instance_type = "t3.medium"

# Database configuration (non-sensitive)
db_username = "ojm"  # Safe: Username is not sensitive
db_name     = "skyline"  # Safe: Database name is not sensitive
# db_password removed for security - managed by AWS Secrets Manager

# EKS configuration (non-sensitive)
cluster_name    = "kdt-dev-eks-cluster"  # Safe: Cluster name is public
cluster_version = "1.33"  # Safe: Version is public information
