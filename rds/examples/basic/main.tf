terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.28" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" { region = var.region }

module "rds" {
  source                 = "../../"
  project                = var.project
  environment            = var.environment
  identifier             = "${var.project}-${var.environment}-pg"
  engine                 = "postgres"
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  deletion_protection    = false
  skip_final_snapshot    = true
}
