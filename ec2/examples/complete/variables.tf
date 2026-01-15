variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ec2-complete"
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
  description = "Remote state key for VPC module. Must match the key in your VPC module's backend.tf. Default matches complete example."
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

variable "enable_ssm_session_manager" {
  description = "Enable SSM Session Manager for secure access"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_enabled" {
  description = "Enable CloudWatch Logs"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

variable "cloudwatch_metrics_enabled" {
  description = "Enable CloudWatch metrics collection"
  type        = bool
  default     = false
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

variable "enable_ipv6" {
  description = "Enable IPv6 support"
  type        = bool
  default     = false
}

variable "enable_eip" {
  description = "Enable Elastic IP for stable public IP address"
  type        = bool
  default     = false
}

variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = false
}

variable "alb_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "alb_target_port" {
  description = "ALB target port (instance port)"
  type        = number
  default     = 80
}

variable "alb_protocol" {
  description = "ALB listener protocol"
  type        = string
  default     = "HTTP"
}

variable "alb_target_protocol" {
  description = "ALB target protocol"
  type        = string
  default     = "HTTP"
}

variable "enable_elb" {
  description = "Enable Classic Load Balancer"
  type        = bool
  default     = false
}

variable "elb_listener_port" {
  description = "ELB listener port"
  type        = number
  default     = 80
}

variable "elb_instance_port" {
  description = "ELB instance port (target port)"
  type        = number
  default     = 80
}

variable "elb_listener_protocol" {
  description = "ELB listener protocol (HTTP, HTTPS, TCP, SSL)"
  type        = string
  default     = "HTTP"
}

variable "spot_instance_enabled" {
  description = "Enable Spot instances"
  type        = bool
  default     = false
}

variable "spot_instance_type" {
  description = "Instance type for Spot instances (optional, uses instance_type if not specified)"
  type        = string
  default     = null
}

variable "spot_interruption_behavior" {
  description = "Spot instance interruption behavior (stop, terminate, hibernate)"
  type        = string
  default     = "terminate"
}

variable "spot_price" {
  description = "Maximum price per hour for Spot instances"
  type        = string
  default     = null
}

variable "enable_autoscaling" {
  description = "Enable Auto Scaling Group (when enabled, instance_count and instances are ignored)"
  type        = bool
  default     = false
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
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
