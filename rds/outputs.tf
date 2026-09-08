output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "RDS address"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "master_user_secret_arn" {
  description = "ARN of RDS-managed master user secret (when manage_master_user_password is true)"
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}
