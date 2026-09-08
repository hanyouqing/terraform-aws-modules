output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

output "iam_user_name" {
  description = "Name of the IAM user for Terraform (null when create_iam_user is false)"
  value       = try(aws_iam_user.terraform[0].name, null)
}

output "iam_user_arn" {
  description = "ARN of the IAM user for Terraform (null when create_iam_user is false)"
  value       = try(aws_iam_user.terraform[0].arn, null)
}

output "iam_access_key_id" {
  description = "Access key ID for the Terraform IAM user (null when keys are not created)"
  value       = try(aws_iam_access_key.terraform[0].id, null)
  sensitive   = true
}

output "iam_secret_access_key" {
  description = "Secret access key for the Terraform IAM user (null when keys are not created)"
  value       = try(aws_iam_access_key.terraform[0].secret, null)
  sensitive   = true
}

output "backend_config" {
  description = "Backend configuration for Terraform S3 backend"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "terraform.tfstate"
    region         = var.region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
  }
}

output "zzz_reminders" {
  description = "Operational reminders for state backend bootstrap"
  value = {
    next_steps = [
      "Bootstrap with a local backend first if the S3 backend does not exist yet.",
      "Prefer AWS SSO / IAM roles over create_iam_access_key = true.",
      "Wire Terragrunt account.hcl state_bucket / state_lock_table to these outputs.",
    ]
    security_notes = [
      "Public access is blocked; TLS < 1.2 is denied by bucket policy.",
      "Never commit access keys; rotate immediately if create_iam_access_key was used.",
    ]
  }
}
