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

variable "log_groups" {
  description = "Map of CloudWatch log groups"
  type = map(object({
    name              = optional(string, null)
    retention_in_days = optional(number, 30)
    kms_key_id        = optional(string, null)
    tags              = optional(map(string), {})
  }))
  default = {}
}

variable "metric_alarms" {
  description = "Map of CloudWatch metric alarms"
  type = map(object({
    alarm_name          = optional(string, null)
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = optional(string, null)
    alarm_actions       = optional(list(string), [])
    ok_actions          = optional(list(string), [])
    treat_missing_data  = optional(string, "notBreaching")
    dimensions          = optional(map(string), {})
    tags                = optional(map(string), {})
  }))
  default = {}
}
