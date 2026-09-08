variable "project" {
  description = "Project name used in default tags"
  type        = string
}

variable "environment" {
  description = "Environment name (development, testing, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production."
  }
}

variable "tags" {
  description = "Additional tags merged into all resources"
  type        = map(string)
  default     = {}
}

variable "buckets" {
  description = "Map of S3 buckets to create. Secure defaults: private, versioned, encrypted."
  type = map(object({
    bucket_prefix             = optional(string, null)
    bucket                    = optional(string, null)
    force_destroy             = optional(bool, false)
    versioning_enabled        = optional(bool, true)
    sse_algorithm             = optional(string, "AES256")
    kms_key_id                = optional(string, null)
    bucket_key_enabled        = optional(bool, true)
    block_public_acls         = optional(bool, true)
    block_public_policy       = optional(bool, true)
    ignore_public_acls        = optional(bool, true)
    restrict_public_buckets   = optional(bool, true)
    object_ownership          = optional(string, "BucketOwnerEnforced")
    lifecycle_noncurrent_days = optional(number, 90)
    enable_lifecycle          = optional(bool, true)
    enable_access_logging     = optional(bool, false)
    access_log_bucket         = optional(string, null)
    access_log_prefix         = optional(string, "s3-access/")
    tags                      = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, b in var.buckets : contains(["AES256", "aws:kms"], b.sse_algorithm)
    ])
    error_message = "sse_algorithm must be AES256 or aws:kms."
  }

  validation {
    condition = alltrue([
      for k, b in var.buckets : (b.bucket != null) != (b.bucket_prefix != null) || (b.bucket == null && b.bucket_prefix == null)
    ])
    error_message = "Provide at most one of bucket or bucket_prefix per entry (both null uses key as bucket name)."
  }
}
