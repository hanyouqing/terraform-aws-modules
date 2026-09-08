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

variable "roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    name                    = optional(string, null)
    path                    = optional(string, "/")
    description             = optional(string, "")
    assume_role_policy      = string
    max_session_duration    = optional(number, 3600)
    permissions_boundary    = optional(string, null)
    managed_policy_arns     = optional(list(string), [])
    inline_policies         = optional(map(string), {})
    create_instance_profile = optional(bool, false)
    tags                    = optional(map(string), {})
  }))
  default = {}
}
