variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ec2-jump"
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
  description = "EC2 instance type for JumpServer"
  type        = string
  default     = "t3.medium"
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "ebs_volume_size" {
  description = "Size of the EBS root volume in GB"
  type        = number
  default     = 60
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

variable "jump_version" {
  description = "JumpServer version to install"
  type        = string
  default     = "v2.28.8"
}

variable "jump_db_host" {
  description = "JumpServer database host (use 'localhost' for local MySQL, or RDS endpoint for external database)"
  type        = string
  default     = "localhost"
}

variable "jump_db_port" {
  description = "JumpServer database port"
  type        = number
  default     = 3306
}

variable "jump_db_user" {
  description = "JumpServer database user"
  type        = string
  default     = "root"
}

variable "jump_db_password" {
  description = "JumpServer database password. If not provided, a random password will be auto-generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "jump_db_name" {
  description = "JumpServer database name"
  type        = string
  default     = "jumpserver"
}

variable "jump_redis_host" {
  description = "JumpServer Redis host (use 'localhost' for local Redis, or ElastiCache endpoint for external Redis)"
  type        = string
  default     = "localhost"
}

variable "jump_redis_port" {
  description = "JumpServer Redis port"
  type        = number
  default     = 6379
}

variable "jump_redis_password" {
  description = "JumpServer Redis password (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "jump_http_port" {
  description = "JumpServer HTTP port"
  type        = number
  default     = 80
}

variable "jump_ssh_port" {
  description = "JumpServer SSH port"
  type        = number
  default     = 2222
}

variable "jump_rdp_port" {
  description = "JumpServer RDP port"
  type        = number
  default     = 3389
}

variable "iam_instance_profile_enabled" {
  description = "Enable IAM instance profile"
  type        = bool
  default     = true
}

variable "enable_rds" {
  description = "Enable RDS access permissions"
  type        = bool
  default     = false
}

variable "enable_ecr" {
  description = "Enable ECR access permissions"
  type        = bool
  default     = false
}

variable "enable_eks" {
  description = "Enable EKS access permissions"
  type        = bool
  default     = false
}

variable "enable_elasticache" {
  description = "Enable ElastiCache access permissions"
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
  description = "Target port on EC2 instances for ALB (JumpServer HTTP port)"
  type        = number
  default     = 80
}

variable "alb_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener (auto-fetched from VPC if not provided)"
  type        = string
  default     = null
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
