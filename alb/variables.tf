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

variable "name" {
  description = "Load balancer name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the load balancer"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the load balancer"
  type        = list(string)
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout seconds"
  type        = number
  default     = 60
}

variable "target_groups" {
  description = "Map of target groups"
  type = map(object({
    port                 = number
    protocol             = optional(string, "HTTP")
    target_type          = optional(string, "instance")
    health_check_path    = optional(string, "/")
    health_check_matcher = optional(string, "200")
    deregistration_delay = optional(number, 30)
  }))
  default = {}
}

variable "http_listeners" {
  description = "Map of HTTP listeners (prefer HTTPS in production)"
  type = map(object({
    port             = optional(number, 80)
    target_group_key = string
  }))
  default = {}
}

variable "https_listeners" {
  description = "Map of HTTPS listeners"
  type = map(object({
    port             = optional(number, 443)
    certificate_arn  = string
    ssl_policy       = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    target_group_key = string
  }))
  default = {}
}
