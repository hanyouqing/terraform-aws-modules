variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "sse_algorithm" {
  description = "SSE algorithm"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "KMS key when using aws:kms"
  type        = string
  default     = null
}

variable "create_iam_user" {
  description = "Create IAM user"
  type        = bool
  default     = false
}

variable "create_iam_access_key" {
  description = "Create access key (requires create_iam_user)"
  type        = bool
  default     = false
}

variable "code" {
  description = "Code tag"
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = null
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}
