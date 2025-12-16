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
  description = "Name of the IAM user for Terraform"
  value       = aws_iam_user.terraform.name
}

output "iam_user_arn" {
  description = "ARN of the IAM user for Terraform"
  value       = aws_iam_user.terraform.arn
}

output "iam_access_key_id" {
  description = "Access key ID for the Terraform IAM user"
  value       = aws_iam_access_key.terraform.id
  sensitive   = true
}

output "iam_secret_access_key" {
  description = "Secret access key for the Terraform IAM user"
  value       = aws_iam_access_key.terraform.secret
  sensitive   = true
}

output "backend_config" {
  description = "Backend configuration for Terraform"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "terraform.tfstate"
    region         = var.region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
  }
}

