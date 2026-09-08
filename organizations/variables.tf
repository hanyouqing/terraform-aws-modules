variable "accounts" {
  description = "List of AWS accounts to create"
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

  validation {
    condition = alltrue([
      for a in var.accounts : contains(["ALLOW", "DENY"], a.iam_user_access_to_billing)
    ])
    error_message = "accounts.*.iam_user_access_to_billing must be ALLOW or DENY."
  }
}

variable "organizational_units" {
  description = "List of organizational units (OUs) to create"
  type = list(object({
    name      = string
    parent_id = optional(string, null)
    tags      = optional(map(string), {})
  }))
  default = []
}

variable "service_control_policies" {
  description = "List of service control policies (SCPs) to create and attach"
  type = list(object({
    name        = string
    description = optional(string, "")
    content     = string
    type        = optional(string, "SERVICE_CONTROL_POLICY")
    targets     = optional(list(string), [])
  }))
  default = []
}

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
  description = "Additional tags merged into all organization resources"
  type        = map(string)
  default     = {}
}
