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

variable "repositories" {
  description = "Map of ECR repositories"
  type = map(object({
    name                       = optional(string, null)
    image_tag_mutability       = optional(string, "IMMUTABLE")
    scan_on_push               = optional(bool, true)
    encryption_type            = optional(string, "AES256")
    kms_key_arn                = optional(string, null)
    force_delete               = optional(bool, false)
    lifecycle_keep_last_images = optional(number, 30)
    enable_lifecycle_policy    = optional(bool, true)
    tags                       = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.repositories : contains(["MUTABLE", "IMMUTABLE"], v.image_tag_mutability)
    ])
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}
