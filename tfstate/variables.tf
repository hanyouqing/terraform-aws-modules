variable "environment" {
  description = "Environment name (testing, staging, production)"
  type        = string

  validation {
    condition     = contains(["testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: testing, staging, production"
  }
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "web3"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state. If not provided, will be generated as '{project}-terraform-state-{environment}'"
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking. If not provided, will be generated as '{project}-terraform-state-lock-{environment}'"
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
    error_message = "SSE algorithm must be either AES256 or aws:kms"
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (required if sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "enable_lifecycle_rule" {
  description = "Enable lifecycle rule for non-current versions"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which non-current versions are deleted"
  type        = number
  default     = 90
}

variable "enable_public_access_block" {
  description = "Enable S3 public access block"
  type        = bool
  default     = true
}

variable "code" {
  description = "Code repository and path (e.g., 'reponame:path/to/terraform/terraform-tfstate')"
  type        = string
  default     = "web3:terraform/terraform-tfstate"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevOps"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

