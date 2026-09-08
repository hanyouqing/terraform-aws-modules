output "key_ids" {
  description = "Map of key IDs"
  value       = { for k, v in aws_kms_key.this : k => v.key_id }
}

output "key_arns" {
  description = "Map of key ARNs"
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "aliases" {
  description = "Map of aliases"
  value       = { for k, v in aws_kms_alias.this : k => v.name }
}
