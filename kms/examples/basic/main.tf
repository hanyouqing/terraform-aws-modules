terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "kms" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  keys        = { app = { alias = "${var.project}-${var.environment}-app" } }
}
