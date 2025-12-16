data "aws_organizations_organization" "main" {}

locals {
  root_id = data.aws_organizations_organization.main.roots[0].id

  accounts_map = {
    for account in var.accounts : account.name => account
  }

  organizational_units_map = {
    for ou in var.organizational_units : ou.name => ou
  }

  service_control_policies_map = {
    for scp in var.service_control_policies : scp.name => scp
  }

  default_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

