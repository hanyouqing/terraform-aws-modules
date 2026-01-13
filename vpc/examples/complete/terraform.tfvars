region = "us-east-1"

project     = "vpc-complete"
environment = "production"

# Use larger CIDR for production scalability
vpc_cidr = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

enable_nat_gateway = true
single_nat_gateway = false # Use multiple NAT Gateways for HA in production

enable_dns_hostnames = true
enable_dns_support   = true

enable_flow_log           = true
flow_log_destination_type = "cloud-watch-logs"

# Allowlist configuration - replace with your actual IPs
allowlist_ipv4_blocks = [
  {
    cidr        = "223.88.177.0/24"
    description = "DevOps"
  }
]

allowlist_ipv6_blocks = []

enable_public_security_group = true

# Domain configuration (optional)
# domain = "example.com"

# VPC Endpoints
enable_vpc_endpoints            = true
enable_ecr_dkr_endpoint         = true
enable_ecr_api_endpoint         = true
enable_eks_endpoint             = true
enable_cloudwatch_logs_endpoint = true
enable_secretsmanager_endpoint  = true
enable_s3_endpoint              = true

tags = {
  Owner      = "DevOps"
  CostCenter = "Infrastructure"
  Code       = "terraform-aws-modules:vpc/examples/complete"
}

