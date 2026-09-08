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

module "organizations" {
  source = "../../"

  project     = var.project
  environment = var.environment
  tags        = var.tags

  accounts                 = var.accounts
  organizational_units     = var.organizational_units
  service_control_policies = var.service_control_policies
}
