locals {
  name = "${var.project}-${var.environment}"

  bucket_name = var.bucket_name != null ? var.bucket_name : "${var.project}-terraform-state-${var.environment}"
  table_name  = var.dynamodb_table_name != null ? var.dynamodb_table_name : "${var.project}-terraform-state-lock-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Module      = "github.com/hanyouqing/terraform-aws-modules/tfstate"
    },
    var.code != null ? { Code = var.code } : {},
    var.owner != null ? { Owner = var.owner } : {},
    var.tags
  )
}
