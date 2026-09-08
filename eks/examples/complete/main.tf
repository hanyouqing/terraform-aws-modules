terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "eks" {
  source = "../../"

  project                 = var.project
  environment             = var.environment
  subnet_ids              = var.subnet_ids
  encryption_kms_key_arn  = var.encryption_kms_key_arn
  endpoint_private_access = true
  endpoint_public_access  = false
  node_desired_size       = 3
  node_min_size           = 2
  node_max_size           = 6
}
