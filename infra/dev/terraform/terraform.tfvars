region = "ap-northeast-2"

project     = "kdt"
environment = "dev"

key_name = "ojm-key"

ami_id = "ami-0d5bb3742db8fc264"

mgmt_instance_type  = "t3.medium"
q_dev_instance_type = "t3.medium"

db_username = "ojm"
# db_password removed for security - use AWS Secrets Manager
db_name = "skyline"

cluster_name = "kdt-dev-eks-cluster"

cluster_version = "1.33"
