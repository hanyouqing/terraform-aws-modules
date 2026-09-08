variable "environment" {
  description = "Environment name (development, testing, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production."
  }
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region for the state bucket and lock table"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state. Defaults to '{project}-terraform-state-{environment}'"
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking. Defaults to '{project}-terraform-state-lock-{environment}'"
  type        = string
  default     = null
}

variable "enable_versioning" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "enable_server_side_encryption" {
  description = "Enable server-side encryption for S3 bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "SSE algorithm must be either AES256 or aws:kms."
  }
}

variable "kms_key_id" {
  description = "KMS key ID/ARN for encryption (required when sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "enable_lifecycle_rule" {
  description = "Enable lifecycle rule for non-current object versions"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which non-current versions are deleted"
  type        = number
  default     = 90
}

variable "enable_public_access_block" {
  description = "Enable S3 public access block (all four settings)"
  type        = bool
  default     = true
}

variable "create_iam_user" {
  description = "Create a dedicated IAM user for Terraform state access (prefer SSO/roles when false)"
  type        = bool
  default     = false
}

variable "create_iam_access_key" {
  description = "Create a long-lived access key for the IAM user (requires create_iam_user = true)"
  type        = bool
  default     = false
}

variable "code" {
  description = "Code repository and path tag (e.g. 'reponame:path/to/tfstate')"
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
