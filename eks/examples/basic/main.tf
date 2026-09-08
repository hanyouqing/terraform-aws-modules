terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "eks" {
  source = "../../"

  project                = var.project
  environment            = var.environment
  subnet_ids             = var.subnet_ids
  endpoint_public_access = false
  # Dev may omit KMS; production examples must set encryption_kms_key_arn
}
