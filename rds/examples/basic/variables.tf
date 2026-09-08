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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "Private/database subnet IDs"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
  default     = []
}
