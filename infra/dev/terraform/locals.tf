locals {
  azs = ["ap-northeast-2a", "ap-northeast-2c"]

  # Naming Convention: {project}-{environment}-{resource-type}-{identifier}
  name_prefix = "${var.project}-${var.environment}"

  # Common tags
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "kdt-team"
  }
}
