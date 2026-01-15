variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ec2-basic"
}

variable "environment" {
  description = "Environment name (development, testing, staging, production)"
  type        = string
  default     = "testing"

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production"
  }
}

variable "vpc_remote_state_bucket" {
  description = "S3 bucket name for VPC remote state"
  type        = string
}

variable "vpc_remote_state_key" {
  description = "Remote state key for VPC module. Must match the key in your VPC module's backend.tf. Default matches basic example."
  type        = string
  default     = "hanyouqing/terraform-aws-modules:vpc/examples/basic/terraform.tfstate"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "domain" {
  description = "Domain name for DNS records (optional). If not set, DNS records will not be created."
  type        = string
  default     = null
}

variable "dns_enabled" {
  description = "Enable DNS record creation in Route53"
  type        = bool
  default     = false
}

variable "dns_ttl" {
  description = "TTL (Time To Live) for DNS records in seconds"
  type        = number
  default     = 60
}

variable "key_path" {
  description = "Path to SSH public key file (e.g., ~/.ssh/id_ed25519.pub). If provided and file exists, will automatically create EC2 Key Pair"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
