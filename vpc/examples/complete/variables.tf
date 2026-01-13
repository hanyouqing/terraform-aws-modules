variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "my-project"
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

variable "vpc_cidr" {
  description = "CIDR block for VPC. For production, consider using a larger CIDR (e.g., /14) for scalability"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost optimization (set to false for production HA)"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination (cloud-watch-logs or s3)"
  type        = string
  default     = "cloud-watch-logs"
}

variable "allowlist_ipv4_blocks" {
  description = "List of IPv4 CIDR blocks to include in the Managed Prefix List allowlist"
  type = list(object({
    cidr        = string
    description = string
  }))
  default = []
}

variable "allowlist_ipv6_blocks" {
  description = "List of IPv6 CIDR blocks to include in the Managed Prefix List allowlist"
  type = list(object({
    cidr        = string
    description = string
  }))
  default = []
}

variable "enable_public_security_group" {
  description = "Enable public security group with allowlist rules"
  type        = bool
  default     = true
}

variable "domain" {
  description = "Base domain name (e.g., example.com). The hosted zone will be created as {environment}.{domain}"
  type        = string
  default     = null
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints"
  type        = bool
  default     = true
}

variable "enable_ecr_dkr_endpoint" {
  description = "Enable ECR Docker API VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_ecr_api_endpoint" {
  description = "Enable ECR API VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_eks_endpoint" {
  description = "Enable EKS API VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs_endpoint" {
  description = "Enable CloudWatch Logs VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_secretsmanager_endpoint" {
  description = "Enable Secrets Manager VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Enable S3 Gateway VPC endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

