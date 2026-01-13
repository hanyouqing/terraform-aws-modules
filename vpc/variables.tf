variable "environment" {
  description = "Environment name (development, testing, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production"
  }
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC. For production environments, consider using a larger CIDR (e.g., /14 or /12) for scalability. For non-production, /16 is typically sufficient."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "availability_zones" {
  description = "List of availability zones. Must match the number of subnets in each tier."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 6
    error_message = "availability_zones must contain between 2 and 6 availability zones for high availability."
  }
}

variable "public_subnet_tags" {
  description = "Additional tags to apply to public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags to apply to private subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags to apply to database subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets. Must be within the VPC CIDR block."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition = alltrue([
      for subnet in var.public_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All public_subnets must be valid CIDR blocks."
  }
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets. Must be within the VPC CIDR block. Count should match availability_zones count."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  validation {
    condition = alltrue([
      for subnet in var.private_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All private_subnets must be valid CIDR blocks."
  }
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets. Must be within the VPC CIDR block. Count should match availability_zones count. Can be empty if database subnets are not needed."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  validation {
    condition = alltrue([
      for subnet in var.database_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All database_subnets must be valid CIDR blocks."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost optimization (testing environment)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
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

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_log_destination_type)
    error_message = "flow_log_destination_type must be either 'cloud-watch-logs' or 's3'."
  }
}

variable "flow_log_destination_arn" {
  description = "ARN of the destination for VPC Flow Logs (S3 bucket ARN or CloudWatch Logs log group ARN). Required if flow_log_destination_type is 's3'."
  type        = string
  default     = null
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the CloudWatch Log Group for VPC Flow Logs. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0 (never expire)."
  type        = number
  default     = 7

  validation {
    condition = contains([
      0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.flow_log_cloudwatch_log_group_retention_in_days)
    error_message = "flow_log_cloudwatch_log_group_retention_in_days must be one of the valid CloudWatch Logs retention period values."
  }
}

variable "code" {
  description = "Code repository and path (e.g., 'reponame:path/to/terraform/vpc')"
  type        = string
  default     = ""
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "assume_role_arn" {
  description = "IAM role ARN to assume for cross-account access (optional)"
  type        = string
  default     = null
}

variable "assume_role_external_id" {
  description = "External ID to use when assuming role (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "assume_role_session_name" {
  description = "Session name to use when assuming role"
  type        = string
  default     = "terraform-vpc"
}

variable "allowlist_ipv4_blocks" {
  description = "List of IPv4 CIDR blocks to include in the Managed Prefix List allowlist"
  type = list(object({
    cidr        = string
    description = string
  }))
  default = []

  validation {
    condition = alltrue([
      for block in var.allowlist_ipv4_blocks : can(cidrhost(block.cidr, 0))
    ])
    error_message = "All allowlist_ipv4_blocks must be valid IPv4 CIDR blocks (e.g., 10.0.0.0/24, not 10.0.0.1/24)."
  }
}

variable "allowlist_ipv6_blocks" {
  description = "List of IPv6 CIDR blocks to include in the Managed Prefix List allowlist"
  type = list(object({
    cidr        = string
    description = string
  }))
  default = []

  validation {
    condition = alltrue([
      for block in var.allowlist_ipv6_blocks : can(cidrhost(block.cidr, 0))
    ])
    error_message = "All allowlist_ipv6_blocks must be valid IPv6 CIDR blocks."
  }
}

variable "enable_public_security_group" {
  description = "Enable public security group with allowlist rules"
  type        = bool
  default     = true
}

variable "public_security_group_allowed_tcp_ports" {
  description = "List of TCP ports to allow from allowlist Managed Prefix List (deprecated: all ports 0-65535 are now allowed to reduce security group rule count)"
  type        = list(number)
  default     = [22, 80, 443]

  validation {
    condition = alltrue([
      for port in var.public_security_group_allowed_tcp_ports : port >= 1 && port <= 65535
    ])
    error_message = "TCP ports must be between 1 and 65535"
  }
}

variable "public_security_group_allowed_udp_ports" {
  description = "List of UDP ports to allow from allowlist Managed Prefix List (deprecated: all ports 0-65535 are now allowed to reduce security group rule count)"
  type        = list(number)
  default     = []

  validation {
    condition = alltrue([
      for port in var.public_security_group_allowed_udp_ports : port >= 1 && port <= 65535
    ])
    error_message = "UDP ports must be between 1 and 65535"
  }
}

variable "enable_ipv6_security_group_rules" {
  description = "Enable IPv6 security group rules. Disable if you hit AWS security group rule limits (60 rules per direction) and don't need IPv6 support."
  type        = bool
  default     = true
}

variable "domain" {
  description = "Base domain name (e.g., example.com). The hosted zone will be created as {environment}.{domain}"
  type        = string
  default     = null
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints. When false, all VPC endpoints are disabled."
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

variable "enable_ssm_endpoint" {
  description = "Enable Systems Manager (SSM) VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ssmmessages_endpoint" {
  description = "Enable Systems Manager Messages (SSM Messages) VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ec2messages_endpoint" {
  description = "Enable EC2 Messages VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_sts_endpoint" {
  description = "Enable Security Token Service (STS) VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB Gateway VPC endpoint"
  type        = bool
  default     = false
}

# IPv6 Support
variable "enable_ipv6" {
  description = "Enable IPv6 support for VPC and subnets"
  type        = bool
  default     = false
}

variable "assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on subnet creation. Requires enable_ipv6 = true"
  type        = bool
  default     = false
}

variable "ipv6_cidr_block" {
  description = "IPv6 CIDR block for VPC. If not specified, AWS will assign one automatically. Requires enable_ipv6 = true. Note: In AWS provider 6.28+, if specified, ipv6_ipam_pool_id must also be provided."
  type        = string
  default     = null
}

variable "public_subnet_ipv6_prefixes" {
  description = "IPv6 CIDR blocks for public subnets. If not specified and enable_ipv6 = true, will be calculated automatically from VPC IPv6 CIDR"
  type        = list(string)
  default     = []
}

variable "private_subnet_ipv6_prefixes" {
  description = "IPv6 CIDR blocks for private subnets. If not specified and enable_ipv6 = true, will be calculated automatically from VPC IPv6 CIDR"
  type        = list(string)
  default     = []
}

variable "database_subnet_ipv6_prefixes" {
  description = "IPv6 CIDR blocks for database subnets. If not specified and enable_ipv6 = true, will be calculated automatically from VPC IPv6 CIDR"
  type        = list(string)
  default     = []
}

# VPC Peering
variable "enable_vpc_peering" {
  description = "Enable VPC peering connections"
  type        = bool
  default     = false
}

variable "vpc_peering_connections" {
  description = "List of VPC peering connections to create"
  type = list(object({
    peer_vpc_id     = string
    peer_region     = optional(string, null)
    peer_owner_id   = optional(string, null)
    auto_accept     = optional(bool, false)
    peer_cidr_block = optional(string, null)
    tags            = optional(map(string), {})
  }))
  default = []
}

variable "vpc_peering_routes" {
  description = "Routes to add for VPC peering connections. Format: { route_key => { route_table_id = \"rtb-xxx\", destination_cidr_block = \"10.1.0.0/16\", peering_connection_key = \"vpc-xxx-0\" } }"
  type = map(object({
    route_table_id         = string
    destination_cidr_block = string
    peering_connection_key = string
  }))
  default = {}
}

# Transit Gateway
variable "enable_transit_gateway" {
  description = "Enable Transit Gateway attachment"
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach to. Required if enable_transit_gateway = true"
  type        = string
  default     = null
}

variable "transit_gateway_dns_support" {
  description = "Enable DNS support for Transit Gateway attachment"
  type        = bool
  default     = true
}

variable "transit_gateway_ipv6_support" {
  description = "Enable IPv6 support for Transit Gateway attachment"
  type        = bool
  default     = false
}

variable "transit_gateway_routes" {
  description = "Routes to add for Transit Gateway. Format: { route_table_id => cidr_block }"
  type        = map(string)
  default     = {}
}

# Automatic CIDR Calculation
variable "enable_auto_cidr" {
  description = "Enable automatic CIDR calculation for subnets from VPC CIDR"
  type        = bool
  default     = false
}

variable "public_subnet_newbits" {
  description = "Number of additional bits for public subnet CIDR calculation. Used when enable_auto_cidr = true"
  type        = number
  default     = 8
}

variable "private_subnet_newbits" {
  description = "Number of additional bits for private subnet CIDR calculation. Used when enable_auto_cidr = true"
  type        = number
  default     = 8
}

variable "database_subnet_newbits" {
  description = "Number of additional bits for database subnet CIDR calculation. Used when enable_auto_cidr = true"
  type        = number
  default     = 8
}

variable "public_subnet_offset" {
  description = "Offset for public subnet CIDR calculation. Used when enable_auto_cidr = true"
  type        = number
  default     = 0
}

variable "private_subnet_offset" {
  description = "Offset for private subnet CIDR calculation. Used when enable_auto_cidr = true"
  type        = number
  default     = 64
}

variable "database_subnet_offset" {
  description = "Offset for database subnet CIDR calculation. Used when enable_auto_cidr = true"
  type        = number
  default     = 128
}

# CloudWatch Monitoring
variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for VPC resources"
  type        = bool
  default     = false
}

variable "enable_cost_anomaly_detection" {
  description = "Enable AWS Cost Anomaly Detection"
  type        = bool
  default     = false
}

variable "cloudwatch_alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications. Required if enable_cloudwatch_alarms = true or enable_cost_anomaly_detection = true"
  type        = string
  default     = null
}

variable "nat_gateway_bandwidth_threshold" {
  description = "Bandwidth threshold in bytes for NAT Gateway alarm (default: 1GB = 1073741824)"
  type        = number
  default     = 1073741824
}

variable "cost_anomaly_detection_monitor_name" {
  description = "Name for the Cost Anomaly Detection monitor"
  type        = string
  default     = null
}

variable "cost_anomaly_detection_threshold" {
  description = "Threshold percentage for cost anomaly detection (default: 50)"
  type        = number
  default     = 50
}

# Network ACLs
variable "enable_network_acls" {
  description = "Enable Network ACLs for defense in depth. Network ACLs provide an additional layer of security at the subnet level."
  type        = bool
  default     = false
}

# Default Security Group
variable "restrict_default_security_group" {
  description = "Restrict default security group to deny all traffic. This is a security best practice."
  type        = bool
  default     = true
}

# Security Group Egress Rules
variable "enable_explicit_egress_rules" {
  description = "Enable explicit egress rules for all security groups. When false, security groups allow all egress by default."
  type        = bool
  default     = false
}

variable "security_group_egress_cidr_blocks" {
  description = "CIDR blocks allowed for security group egress rules. Used when enable_explicit_egress_rules = true"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Database Security Group Rules
variable "database_security_group_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access database security group. Should typically be private subnet CIDRs. If empty, only private security group access is allowed."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.database_security_group_allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All database_security_group_allowed_cidr_blocks must be valid CIDR blocks."
  }
}

variable "database_security_group_allowed_ports" {
  description = "Ports allowed for database security group ingress. Common database ports: 1433 (SQL Server), 3306 (MySQL), 5432 (PostgreSQL), 6379 (Redis), 27017 (MongoDB)"
  type        = list(number)
  default     = [1433, 3306, 5432, 6379, 27017]

  validation {
    condition = alltrue([
      for port in var.database_security_group_allowed_ports : port >= 1 && port <= 65535
    ])
    error_message = "All database_security_group_allowed_ports must be between 1 and 65535."
  }
}

# Public Security Group Allowlist
variable "public_security_group_allowlist_enabled" {
  description = "Enable allowlist rules for public security group. When enabled, only allowlist IPs can access public resources."
  type        = bool
  default     = false
}

# VPC Endpoint Policies
variable "vpc_endpoint_policy_enabled" {
  description = "Enable VPC endpoint policies for access control. When enabled, endpoints will have restrictive policies."
  type        = bool
  default     = false
}

# Encryption
variable "cloudwatch_logs_encryption_enabled" {
  description = "Enable encryption for CloudWatch Logs (KMS)"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_kms_key_id" {
  description = "KMS key ID for CloudWatch Logs encryption. Required if cloudwatch_logs_encryption_enabled = true"
  type        = string
  default     = null
}

variable "flow_log_s3_encryption_enabled" {
  description = "Enable encryption for S3 Flow Logs destination"
  type        = bool
  default     = true
}

