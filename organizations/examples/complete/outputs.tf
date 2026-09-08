output "organization_id" {
  value       = module.organizations.organization_id
  description = "AWS Organizations organization ID"
}

output "organization_arn" {
  value       = module.organizations.organization_arn
  description = "AWS Organizations organization ARN"
}

output "master_account_id" {
  value       = module.organizations.master_account_id
  description = "AWS Organizations master account ID"
}

output "accounts" {
  value       = module.organizations.accounts
  description = "Created AWS accounts"
}

output "organizational_units" {
  value       = module.organizations.organizational_units
  description = "Created organizational units"
}

output "service_control_policies" {
  value       = module.organizations.service_control_policies
  description = "Created service control policies"
}

