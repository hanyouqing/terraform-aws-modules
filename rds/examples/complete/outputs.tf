output "endpoint" { value = module.rds.db_instance_endpoint }
output "secret_arn" { value = module.rds.master_user_secret_arn }
