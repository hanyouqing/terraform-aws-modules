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

variable "keys" {
  description = "Map of KMS keys to create"
  type = map(object({
    description             = optional(string, "Customer managed KMS key")
    deletion_window_in_days = optional(number, 30)
    enable_key_rotation     = optional(bool, true)
    multi_region            = optional(bool, false)
    alias                   = optional(string, null)
    policy                  = optional(string, null)
    tags                    = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.keys : v.deletion_window_in_days >= 7 && v.deletion_window_in_days <= 30
    ])
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}
