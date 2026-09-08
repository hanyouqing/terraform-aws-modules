output "secret_arns" {
  description = "Map of secret ARNs"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_ids" {
  description = "Map of secret IDs/names"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.id }
}
