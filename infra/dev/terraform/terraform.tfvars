# 🚀 Auto-generated Terraform variables
# Generated from infrastructure-spec.yml
# Do not edit manually - changes will be overwritten

# 🌍 Basic Configuration
region = "ap-northeast-2"
project = "kdt"
environment = "dev"

# 🌐 Network Configuration
vpc_cidr = "10.30.0.0/16"
public_subnet_cidrs = ["10.30.10.0/24", "10.30.20.0/24"]
private_mgmt_subnet_cidrs = ["10.30.11.0/24", "10.30.21.0/24"]
private_ng_subnet_cidrs = ["10.30.12.0/23", "10.30.22.0/23"]
private_rds_subnet_cidrs = ["10.30.14.0/24", "10.30.24.0/24"]
private_qdev_subnet_cidrs = ["10.30.15.0/24", "10.30.25.0/24"]

# 🖥️ Compute Configuration
ami_id = "ami-0d5bb3742db8fc264"
mgmt_instance_type = "t3.medium"
q_dev_instance_type = "t3.medium"
key_name = "ojm-key"

# ☸️ Kubernetes Configuration
cluster_name = "kdt-dev-eks-cluster"
cluster_version = "1.33"
node_instance_types = ["t3.medium"]
node_desired_size = 2
node_min_size = 1
node_max_size = 4

# 🗄️ Database Configuration
db_username = "ojm"
db_name = "skyline"
db_engine = "mysql"
db_engine_version = "8.0.41"
db_instance_class = "db.t3.micro"
