locals {
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "github.com/hanyouqing/terraform-aws-modules/sns"
    },
    var.tags
  )
}
