terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "s3" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  buckets = {
    app = {
      versioning_enabled        = true
      sse_algorithm             = "AES256"
      lifecycle_noncurrent_days = 30
    }
  }
  tags = { Owner = "platform" }
}
