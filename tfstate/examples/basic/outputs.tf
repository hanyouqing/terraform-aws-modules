output "backend_config" {
  description = "S3 backend configuration"
  value       = module.tfstate.backend_config
}

output "s3_bucket_name" {
  description = "State bucket name"
  value       = module.tfstate.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Lock table name"
  value       = module.tfstate.dynamodb_table_name
}
