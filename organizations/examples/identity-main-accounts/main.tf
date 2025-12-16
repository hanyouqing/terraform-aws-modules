terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
}

module "organizations" {
  source = "../../"

  region = var.region

  project     = var.project
  environment = var.environment
  tags        = var.tags

  accounts                 = var.accounts
  organizational_units     = var.organizational_units
  service_control_policies = var.service_control_policies
}

data "aws_organizations_organization" "main" {}

locals {
  identity_account_id = module.organizations.accounts["identity"].id
  main_account_id     = module.organizations.accounts["main"].id
}

output "identity_account_id" {
  value       = local.identity_account_id
  description = "Identity account ID"
}

output "main_account_id" {
  value       = local.main_account_id
  description = "Main account ID"
}

output "identity_account_arn" {
  value       = module.organizations.accounts["identity"].arn
  description = "Identity account ARN"
}

output "main_account_arn" {
  value       = module.organizations.accounts["main"].arn
  description = "Main account ARN"
}

