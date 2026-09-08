terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.28" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" { region = var.region }

module "rds" {
  source                       = "../../"
  project                      = var.project
  environment                  = var.environment
  identifier                   = "${var.project}-${var.environment}-pg"
  engine                       = "postgres"
  instance_class               = "db.t4g.small"
  multi_az                     = true
  subnet_ids                   = var.subnet_ids
  vpc_security_group_ids       = var.vpc_security_group_ids
  backup_retention_period      = 14
  performance_insights_enabled = true
}
