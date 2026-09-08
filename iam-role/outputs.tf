output "role_arns" {
  description = "Map of role ARNs"
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}

output "role_names" {
  description = "Map of role names"
  value       = { for k, v in aws_iam_role.this : k => v.name }
}

output "instance_profile_arns" {
  description = "Map of instance profile ARNs"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.arn }
}
