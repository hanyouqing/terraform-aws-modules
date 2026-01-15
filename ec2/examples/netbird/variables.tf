variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ec2-netbird"
}

variable "environment" {
  description = "Environment name (development, testing, staging, production)"
  type        = string
  default     = "production"

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
  description = "Remote state key for VPC module. Must match the key in your VPC module's backend.tf."
  type        = string
  default     = "hanyouqing/terraform-aws-modules:vpc/examples/complete/terraform.tfstate"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "ebs_volume_size" {
  description = "Size of the EBS root volume in GB"
  type        = number
  default     = 8
}

variable "ebs_volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp3"
}

variable "ebs_encrypted" {
  description = "Enable encryption for EBS volume"
  type        = bool
  default     = true
}

variable "enable_termination_protection" {
  description = "Enable termination protection for the instance"
  type        = bool
  default     = false
}

variable "netbird_setup_key" {
  description = "NetBird setup key for connecting to the NetBird network. Get this from your NetBird Management Dashboard"
  type        = string
  sensitive   = true
}

variable "netbird_management_url" {
  description = "NetBird management URL (optional). If not specified, uses the default NetBird cloud management. Use this if you have a self-hosted NetBird management server"
  type        = string
  default     = null
}

variable "enable_ssm_session_manager" {
  description = "Enable SSM Session Manager for secure access"
  type        = bool
  default     = true
}

variable "enable_eip" {
  description = "Enable Elastic IP for stable public IP address"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Base domain for DNS records"
  type        = string
  default     = null
}

variable "dns_enabled" {
  description = "Enable Route53 DNS records"
  type        = bool
  default     = false
}

variable "dns_ttl" {
  description = "TTL for Route53 DNS records in seconds"
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
