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

variable "cluster_name" {
  description = "ECS cluster name. Defaults to {project}-{environment}."
  type        = string
  default     = null
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "enable_fargate_capacity_providers" {
  description = "Associate FARGATE and FARGATE_SPOT capacity providers"
  type        = bool
  default     = true
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = [
    { capacity_provider = "FARGATE", weight = 1, base = 1 }
  ]
}

variable "create_cloudwatch_log_group" {
  description = "Create a default log group for tasks"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Log retention days"
  type        = number
  default     = 30
}

variable "execute_command_logging" {
  description = "ECS Exec logging configuration mode: NONE, DEFAULT, or OVERRIDE"
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["NONE", "DEFAULT", "OVERRIDE"], var.execute_command_logging)
    error_message = "execute_command_logging must be NONE, DEFAULT, or OVERRIDE."
  }
}
