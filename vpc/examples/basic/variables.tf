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
  default     = "testing"

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones. Using 2 AZs reduces resource count (cost remains similar as NAT Gateway is disabled by default)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets. Reduced to 2 subnets for minimal cost (matches availability_zones count)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets. Reduced to 2 subnets for minimal cost (matches availability_zones count)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets. Reduced to 2 subnets for minimal cost (matches availability_zones count). Can be empty [] if not needed"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets. Set to false for minimal cost (private subnets won't have internet access)"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost optimization (only used if enable_nat_gateway = true)"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs. Set to false for minimal cost"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC Endpoints. Set to false for minimal cost"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Base domain name for Route 53 hosted zone (e.g., aws.hanyouqing.com)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

