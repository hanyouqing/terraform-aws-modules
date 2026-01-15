variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ec2-gitlab"
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
  description = "EC2 instance type for GitLab"
  type        = string
  default     = "t3.large"
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "ebs_volume_size" {
  description = "Size of the EBS root volume in GB"
  type        = number
  default     = 100
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
  default     = true
}

variable "gitlab_external_url" {
  description = "External URL for GitLab (e.g., https://gitlab.example.com)"
  type        = string
  default     = "http://gitlab.example.com"
}

variable "gitlab_http_port" {
  description = "GitLab HTTP port"
  type        = number
  default     = 80
}

variable "gitlab_https_port" {
  description = "GitLab HTTPS port"
  type        = number
  default     = 443
}

variable "gitlab_ssh_port" {
  description = "GitLab SSH port"
  type        = number
  default     = 22
}

variable "iam_instance_profile_enabled" {
  description = "Enable IAM instance profile"
  type        = bool
  default     = true
}

variable "enable_ecr" {
  description = "Enable ECR access permissions (for container registry)"
  type        = bool
  default     = false
}

variable "enable_ssm_session_manager" {
  description = "Enable SSM Session Manager for secure access"
  type        = bool
  default     = true
}

variable "enable_eip" {
  description = "Enable Elastic IP for stable public IP address"
  type        = bool
  default     = true
}

variable "enable_alb" {
  description = "Enable Application Load Balancer for HTTPS and security"
  type        = bool
  default     = true
}

variable "alb_port" {
  description = "ALB listener port (443 for HTTPS, 80 for HTTP)"
  type        = number
  default     = 443
}

variable "alb_protocol" {
  description = "ALB listener protocol (HTTPS recommended for security)"
  type        = string
  default     = "HTTPS"
}

variable "alb_target_port" {
  description = "Target port on EC2 instances for ALB (GitLab HTTP port)"
  type        = number
  default     = 80
}

variable "alb_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener (auto-fetched from VPC if not provided)"
  type        = string
  default     = null
}

variable "domain" {
  description = "Base domain for DNS records"
  type        = string
  default     = null
}

variable "dns_enabled" {
  description = "Enable Route53 DNS records"
  type        = bool
  default     = true
}

variable "dns_ttl" {
  description = "TTL for Route53 DNS records in seconds"
  type        = number
  default     = 60
}

variable "jump_server_host" {
  description = "Jump server hostname or IP address for SSH proxy (e.g., jump.production.aws.hanyouqing.com or 1.2.3.4)"
  type        = string
  default     = null
}

variable "jump_server_user" {
  description = "Jump server SSH user (default: ubuntu)"
  type        = string
  default     = "ubuntu"
}

variable "jump_server_port" {
  description = "Jump server SSH port (default: 22)"
  type        = number
  default     = 22
}

variable "jump_server_identity_file" {
  description = "SSH identity file for jump server (default: ~/.ssh/jump-production)"
  type        = string
  default     = "~/.ssh/jump-production"
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
