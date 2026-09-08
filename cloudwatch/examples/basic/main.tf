terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "cloudwatch" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  log_groups  = { app = { retention_in_days = 14 } }
}
