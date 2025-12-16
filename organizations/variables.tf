variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key ID. Can be set via AWS_ACCESS_KEY_ID environment variable."
  type        = string
  default     = null
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key. Can be set via AWS_SECRET_ACCESS_KEY environment variable."
  type        = string
  default     = null
  sensitive   = true
}

variable "aws_profile" {
  description = "AWS profile name from ~/.aws/credentials. Can be set via AWS_PROFILE environment variable."
  type        = string
  default     = null
}

variable "aws_session_token" {
  description = "AWS session token for temporary credentials. Can be set via AWS_SESSION_TOKEN environment variable."
  type        = string
  default     = null
  sensitive   = true
}

variable "aws_assume_role_arn" {
  description = "ARN of the IAM role to assume"
  type        = string
  default     = null
}

variable "aws_assume_role_session_name" {
  description = "Session name for assume role"
  type        = string
  default     = "terraform-organizations-module"
}

variable "aws_assume_role_external_id" {
  description = "External ID for assume role"
  type        = string
  default     = null
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

variable "project" {
  description = "Project name"
  type        = string
  default     = "web3"
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

