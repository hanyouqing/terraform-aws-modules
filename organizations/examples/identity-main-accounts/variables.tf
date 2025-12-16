variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "identity-main"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "accounts" {
  description = "List of AWS accounts to create"
  type = list(object({
    name                       = string
    email                      = string
    iam_user_access_to_billing = optional(string, "ALLOW")
    role_name                  = optional(string, "OrganizationAccountAccessRole")
    close_on_deletion          = optional(bool, false)
    tags                       = optional(map(string), {})
  }))
  default = []
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

