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

variable "secrets" {
  description = "Map of Secrets Manager secrets. Prefer generating values outside Terraform when possible."
  type = map(object({
    name                    = optional(string, null)
    description             = optional(string, "")
    kms_key_id              = optional(string, null)
    recovery_window_in_days = optional(number, 30)
    secret_string           = optional(string, null)
    secret_key_value        = optional(map(string), null)
    tags                    = optional(map(string), {})
  }))
  default = {}
}
