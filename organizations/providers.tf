provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  profile    = var.aws_profile
  token      = var.aws_session_token

  dynamic "assume_role" {
    for_each = var.aws_assume_role_arn != null ? [1] : []
    content {
      role_arn     = var.aws_assume_role_arn
      session_name = var.aws_assume_role_session_name
      external_id  = var.aws_assume_role_external_id
    }
  }

  default_tags {
    tags = merge(
      {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}

