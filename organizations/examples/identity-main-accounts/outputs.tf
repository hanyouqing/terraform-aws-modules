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

output "identity_account_id" {
  value       = module.organizations.accounts["identity"].id
  description = "Identity account ID - use this for assume role configuration"
}

output "main_account_id" {
  value       = module.organizations.accounts["main"].id
  description = "Main account ID - use this for assume role configuration"
}

