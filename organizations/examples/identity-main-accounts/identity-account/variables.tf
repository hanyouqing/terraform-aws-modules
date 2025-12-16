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
  description = "ARN of the IAM role to assume. Use this to assume OrganizationAccountAccessRole in identity account."
  type        = string
  default     = null
}

variable "aws_assume_role_session_name" {
  description = "Session name for assume role"
  type        = string
  default     = "terraform-identity-setup"
}

variable "aws_assume_role_external_id" {
  description = "External ID for assume role"
  type        = string
  default     = null
}

variable "identity_account_id" {
  description = "Identity account ID"
  type        = string
}

variable "main_account_id" {
  description = "Main account ID"
  type        = string
}

variable "sso_permission_set_arns" {
  description = "List of SSO permission set ARNs that can assume these roles. Leave empty if not using SSO yet."
  type        = list(string)
  default     = []
}

variable "team_roles" {
  description = "Map of team roles to create in identity account for assuming main account roles"
  type = map(object({
    role_name       = string
    target_role_name = string
    external_id     = string
  }))
  default = {
    developers = {
      role_name       = "AssumeMainAccount-Developers"
      target_role_name = "Developers"
      external_id     = "assume-main-developers"
    }
    operations = {
      role_name       = "AssumeMainAccount-Operations"
      target_role_name = "Operations"
      external_id     = "assume-main-operations"
    }
  }
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

