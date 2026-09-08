locals {
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "github.com/hanyouqing/terraform-aws-modules/ecs"
    },
    var.tags
  )
  name = coalesce(var.cluster_name, "${var.project}-${var.environment}")
}
