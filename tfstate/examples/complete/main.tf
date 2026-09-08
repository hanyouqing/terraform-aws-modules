terraform {
  required_version = ">= 1.14.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tfstate" {
  source = "../../"

  project     = var.project
  environment = var.environment
  region      = var.region

  enable_versioning             = true
  enable_server_side_encryption = true
  sse_algorithm                 = var.sse_algorithm
  kms_key_id                    = var.kms_key_id
  enable_lifecycle_rule         = true
  enable_public_access_block    = true

  # Prefer roles; enable only for break-glass local bootstrap.
  create_iam_user       = var.create_iam_user
  create_iam_access_key = var.create_iam_access_key

  code  = var.code
  owner = var.owner
  tags  = var.tags
}
