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

variable "topics" {
  description = "Map of SNS topics"
  type = map(object({
    name                        = optional(string, null)
    kms_master_key_id           = optional(string, null)
    display_name                = optional(string, null)
    fifo_topic                  = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    subscriptions = optional(list(object({
      protocol = string
      endpoint = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
