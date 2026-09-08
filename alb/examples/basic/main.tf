terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "alb" {
  source                     = "../../"
  project                    = var.project
  environment                = var.environment
  name                       = "${var.project}-${var.environment}-alb"
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.subnet_ids
  security_group_ids         = var.security_group_ids
  enable_deletion_protection = false
  target_groups = {
    app = { port = 80, health_check_path = "/health" }
  }
  http_listeners = {
    default = { target_group_key = "app" }
  }
}
