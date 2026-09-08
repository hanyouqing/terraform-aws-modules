variable "region" {
  description = "AWS region for the provider (Organizations is global; still required by the provider)"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production."
  }
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "accounts" {
  description = "Accounts to create"
  type = list(object({
    name                       = string
    email                      = string
    parent_id                  = optional(string, null)
    iam_user_access_to_billing = optional(string, "ALLOW")
    role_name                  = optional(string, "OrganizationAccountAccessRole")
    close_on_deletion          = optional(bool, false)
    tags                       = optional(map(string), {})
  }))
  default = []
}

variable "organizational_units" {
  description = "OUs to create"
  type = list(object({
    name      = string
    parent_id = optional(string, null)
    tags      = optional(map(string), {})
  }))
  default = []
}

variable "service_control_policies" {
  description = "SCPs to create"
  type = list(object({
    name        = string
    description = optional(string, "")
    content     = string
    type        = optional(string, "SERVICE_CONTROL_POLICY")
    targets     = optional(list(string), [])
  }))
  default = []
}
