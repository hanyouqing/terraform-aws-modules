output "organization_id" {
  value       = data.aws_organizations_organization.main.id
  description = "AWS Organizations organization ID"
}

output "organization_arn" {
  value       = data.aws_organizations_organization.main.arn
  description = "AWS Organizations organization ARN"
}

output "master_account_id" {
  value       = data.aws_organizations_organization.main.master_account_id
  description = "AWS Organizations master account ID"
}

output "master_account_email" {
  value       = data.aws_organizations_organization.main.master_account_email
  description = "AWS Organizations master account email"
}

output "accounts" {
  value = {
    for k, v in aws_organizations_account.accounts : k => {
      id               = v.id
      arn              = v.arn
      name             = v.name
      email            = v.email
      status           = v.status
      joined_method    = v.joined_method
      joined_timestamp = v.joined_timestamp
    }
  }
  description = "Created AWS accounts"
}

output "organizational_units" {
  value = {
    for k, v in aws_organizations_organizational_unit.ous : k => {
      id        = v.id
      arn       = v.arn
      name      = v.name
      parent_id = v.parent_id
    }
  }
  description = "Created organizational units"
}

output "service_control_policies" {
  value = {
    for k, v in aws_organizations_policy.scps : k => {
      id          = v.id
      arn         = v.arn
      name        = v.name
      type        = v.type
      description = v.description
    }
  }
  description = "Created service control policies"
}

