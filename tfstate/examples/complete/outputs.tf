output "backend_config" {
  description = "S3 backend configuration"
  value       = module.tfstate.backend_config
}

output "iam_user_arn" {
  description = "IAM user ARN when created"
  value       = module.tfstate.iam_user_arn
}

output "zzz_reminders" {
  description = "Operational reminders"
  value       = module.tfstate.zzz_reminders
}
