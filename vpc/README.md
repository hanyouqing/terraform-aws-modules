# VPC Terraform Module

A production-ready Terraform module for creating AWS VPCs with public, private, and database subnets across multiple availability zones.

## Features

- ✅ Multi-AZ VPC with public, private, and database subnets
- ✅ Internet Gateway for public subnets
- ✅ NAT Gateway(s) for private subnets (single or multi-AZ)
- ✅ VPC Flow Logs (CloudWatch Logs or S3)
- ✅ DNS support and hostnames enabled
- ✅ Managed Prefix List for allowlist (IPv4 and IPv6)
- ✅ Security groups (jump, public, private, database, VPC endpoints)
- ✅ VPC Endpoints (ECR, EKS, CloudWatch Logs, Secrets Manager, S3)
- ✅ Route 53 hosted zone (optional, automatically creates both public and private zones when domain is specified)
- ✅ Private Route 53 hosted zone automatically associated with VPC (for internal services like Redis, Database, etc.)
- ✅ ACM certificate (optional, requires domain)
- ✅ Cost-optimized for non-production environments

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "path/to/vpc"

  project     = "my-project"
  environment = "testing"
  region      = "us-east-1"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Cost optimization for non-production

  tags = {
    Owner      = "Team"
    CostCenter = "Infrastructure"
  }
}
```

### Complete Example with All Features

```hcl
module "vpc" {
  source = "path/to/vpc"

  project     = "my-project"
  environment = "production"
  region      = "us-east-1"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false  # Multiple NAT Gateways for HA

  # Allowlist configuration
  allowlist_ipv4_blocks = [
    {
      cidr        = "203.0.113.0/24"
      description = "Office network"
    }
  ]

  # Domain and DNS
  domain = "hanyouqing.com"

  # VPC Endpoints
  enable_vpc_endpoints = true

  tags = {
    Owner      = "Team"
    CostCenter = "Infrastructure"
  }
}
```

## Examples

See the [examples](./examples/) directory for ready-to-use configurations:

- **[basic](./examples/basic/)**: Minimal VPC configuration for testing
- **[complete](./examples/complete/)**: Production-ready configuration with all features

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14 |
| aws | ~> 6.28 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.28 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | `""` | no |
| environment | Environment name (testing, staging, production) | `string` | n/a | yes |
| region | AWS region | `string` | `"us-east-1"` | no |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | List of availability zones | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no |
| public_subnets | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | no |
| private_subnets | CIDR blocks for private subnets | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]` | no |
| database_subnets | CIDR blocks for database subnets | `list(string)` | `["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]` | no |
| enable_nat_gateway | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| single_nat_gateway | Use single NAT Gateway for cost optimization | `bool` | `false` | no |
| enable_flow_log | Enable VPC Flow Logs | `bool` | `true` | no |
| allowlist_ipv4_blocks | List of IPv4 CIDR blocks for Managed Prefix List | `list(object)` | `[]` | no |
| domain | Base domain name (e.g., example.com). When specified, creates both public and private Route53 hosted zones for {environment}.{domain}. The private hosted zone is automatically associated with the VPC. | `string` | `null` | no |
| enable_vpc_endpoints | Enable VPC endpoints | `bool` | `true` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

See [variables.tf](./variables.tf) for the complete list of available variables.

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_name | Name of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| public_subnet_ids | IDs of the public subnets (list format) |
| public_subnet_ids_map | Map of public subnet IDs by name (format: {name => id}) |
| private_subnet_ids | IDs of the private subnets (list format) |
| private_subnet_ids_map | Map of private subnet IDs by name (format: {name => id}) |
| database_subnet_ids | IDs of the database subnets (list format) |
| database_subnet_ids_map | Map of database subnet IDs by name (format: {name => id}) |
| nat_gateway_ids | IDs of the NAT Gateways (list format) |
| nat_gateway_ids_map | Map of NAT Gateway IDs by name (format: {name => id}) |
| nat_public_ips | Public IPs of NAT Gateways (list format, for backward compatibility) |
| nat_public_ips_map | Map of NAT Gateway public IPs by name (format: {name => public_ip}) |
| nat_gateway_public_ips | Map of NAT Gateway public IPs by name (format: {name => public_ip}) |
| internet_gateway_id | ID of the Internet Gateway |
| internet_gateway_arn | ARN of the Internet Gateway |
| allowlist_prefix_list_id_ipv4 | ID of the IPv4 Managed Prefix List for allowlist |
| allowlist_prefix_list_arn_ipv4 | ARN of the IPv4 Managed Prefix List for allowlist |
| allowlist_prefix_list_name_ipv4 | Name of the IPv4 Managed Prefix List for allowlist |
| allowlist_prefix_list_id_ipv6 | ID of the IPv6 Managed Prefix List for allowlist |
| allowlist_prefix_list_arn_ipv6 | ARN of the IPv6 Managed Prefix List for allowlist |
| allowlist_prefix_list_name_ipv6 | Name of the IPv6 Managed Prefix List for allowlist |
| allowlist_prefix_list_ids_map | Map of allowlist prefix list IDs by name (format: {name => id}) |
| allowlist_prefix_list_arns_map | Map of allowlist prefix list ARNs by name (format: {name => arn}) |
| jump_security_group_id | ID of the jump security group |
| public_security_group_id | ID of the public security group |
| private_security_group_id | ID of the private security group |
| database_security_group_id | ID of the database security group |
| security_group_ids | IDs of all security groups (list format, for backward compatibility) |
| security_group_ids_map | Map of all security groups (format: {jump => id, public => id, private => id, database => id}) |
| vpc_endpoints_security_group_id | ID of the VPC endpoints security group |
| hosted_zone_id | ID of the Route 53 hosted zone (if domain is set) |
| hosted_zone_name | Name of the Route 53 hosted zone (if domain is set) |
| hosted_zone_arn | ARN of the Route 53 hosted zone (if domain is set) |
| hosted_zone_name_servers | Name servers for the Route 53 hosted zone (if domain is set) |
| hosted_zone_name_servers_list | List of name servers for easy copy-paste (if domain is set) |
| hosted_zone_ns_records | NS records formatted for DNS providers (if domain is set) |
| hosted_zone_ns_records_formatted | NS records in formatted string for easy copy-paste (if domain is set) |
| hosted_zone_ns_records_cloudflare | NS records formatted for Cloudflare DNS in JSON format (if domain is set) |
| hosted_zone_ns_records_list | List of NS record values (name servers) for programmatic use (if domain is set) |
| zzz_hosted_zone_delegation_instructions | Detailed instructions for delegating subdomain to Route53 (if domain is set) |
| private_hosted_zone_id | ID of the Route 53 private hosted zone for internal services (automatically created when domain is specified). Uses the same domain as public hosted zone. |
| private_hosted_zone_name | Name of the Route 53 private hosted zone ({environment}.{domain}, same as public hosted zone) |
| private_hosted_zone_arn | ARN of the Route 53 private hosted zone for internal services |
| private_hosted_zone_name_servers | Name servers for the Route 53 private hosted zone (for internal services) |
| route53_zone_ids_map | Map of Route53 hosted zone IDs by name (format: {name => zone_id}) |
| route53_zone_arns_map | Map of Route53 hosted zone ARNs by name (format: {name => arn}) |
| route53_zone_name_servers_map | Map of Route53 hosted zone name servers by name (format: {name => [name_servers]}) |
| acm_certificate_arn | ARN of the ACM certificate (if domain is set) |
| acm_certificate_id | ID of the ACM certificate (if domain is set) |
| acm_certificate_domain_name | Domain name of the ACM certificate (if domain is set) |
| acm_certificate_subject_alternative_names | List of subject alternative names (SANs) for the ACM certificate (if domain is set) |
| acm_certificate_validation_method | Validation method used for the ACM certificate (if domain is set) |
| acm_certificate_status | Status of the ACM certificate validation (if domain is set) |
| acm_certificate_validation_record_fqdns | List of FQDNs for DNS validation records (if domain is set) |

See [outputs.tf](./outputs.tf) for the complete list of available outputs.

## Cost Considerations

### Monthly Cost Breakdown

#### Basic Configuration (Non-Production)
- **NAT Gateway** (single): ~$32/month
- **VPC Flow Logs**: ~$5-10/month
- **Total**: ~$40-50/month

#### Complete Configuration (Production)
- **NAT Gateways** (3 AZs): ~$96/month (3 × $32)
  - Use `single_nat_gateway = true` for non-production: ~$32/month
- **VPC Endpoints** (Interface): ~$7/month per endpoint × 5 = ~$35/month
  - ECR DKR, ECR API, EKS, CloudWatch Logs, Secrets Manager
- **VPC Endpoint** (Gateway - S3): Free
- **VPC Flow Logs**: ~$5-10/month
- **Route 53 Hosted Zone**: ~$0.50/month
- **ACM Certificate**: Free
- **Managed Prefix List**: Free
- **Total**: ~$140-150/month (production) or ~$75-85/month (non-production)

### Cost Optimization Strategies

1. **Non-Production Environments**:
   - Set `single_nat_gateway = true` to save ~$64/month
   - Disable unnecessary VPC endpoints
   - Use smaller CIDR blocks

2. **Production Environments**:
   - Use multiple NAT Gateways for high availability
   - Enable all VPC endpoints for security and reduced data transfer costs
   - Use larger CIDR blocks for scalability (e.g., /14 instead of /16)

3. **Cost Scaling**:
   - **Small**: Single NAT Gateway, minimal endpoints (~$40-50/month)
   - **Medium**: Single NAT Gateway, all endpoints (~$75-85/month)
   - **Large**: Multiple NAT Gateways, all endpoints (~$140-150/month)
   - **Enterprise**: Multiple NAT Gateways, all endpoints, larger CIDR (~$140-150/month + data transfer)

### Cost Reduction Strategies

- **Environment-Specific**: Use `single_nat_gateway = true` for testing/staging
- **Monitoring**: Enable VPC Flow Logs to identify unused resources
- **Right-Sizing**: Use appropriate CIDR block sizes (don't over-provision)
- **VPC Endpoints**: Enable VPC endpoints to reduce data transfer costs (traffic stays within AWS network)

## Architecture

The module creates the following resources:

```
VPC (10.0.0.0/16)
├── Public Subnets (3 AZs)
│   ├── Internet Gateway
│   └── Route Table (public)
├── Private Subnets (3 AZs)
│   ├── NAT Gateway(s)
│   └── Route Table (private)
├── Database Subnets (3 AZs)
│   └── Route Table (database, isolated)
├── Security Groups
│   ├── Jump (bastion)
│   ├── Public
│   ├── Private
│   ├── Database
│   └── VPC Endpoints
├── VPC Endpoints
│   ├── ECR DKR (Interface)
│   ├── ECR API (Interface)
│   ├── EKS (Interface)
│   ├── CloudWatch Logs (Interface)
│   ├── Secrets Manager (Interface)
│   └── S3 (Gateway)
├── Managed Prefix List (Allowlist)
├── Route 53 Hosted Zone (optional)
└── ACM Certificate (optional)
```

## Security Considerations

1. **Allowlist**: Always configure `allowlist_ipv4_blocks` with your actual IPs. Never use `0.0.0.0/0` in production.

2. **Security Groups**: The module creates security groups with appropriate rules. Review and adjust as needed.

3. **VPC Endpoints**: Enable VPC endpoints to keep traffic within AWS network (improves security and reduces data transfer costs).

4. **Flow Logs**: Enable VPC Flow Logs for network monitoring and security auditing.

5. **Database Subnets**: Database subnets are isolated (no internet gateway or NAT gateway routes).

## Required Tags

All resources are automatically tagged with:

- **Environment**: testing, staging, or production
- **Project**: Project name
- **ManagedBy**: terraform
- **Code**: Repository and path (e.g., `terraform-aws-modules:vpc`)
- **Owner**: Resource owner

Additional tags can be provided via the `tags` variable.

## Naming Convention

Resources follow the format: `{project-name}-{environment}`

- Example: `my-project-testing`, `my-project-production`

## IAM Permissions

The AWS credentials used must have permissions for:

- VPC, Subnet, Route Table, Internet Gateway, NAT Gateway management
- VPC Flow Logs (including CloudWatch Logs and IAM role creation)
- RDS Subnet Group management
- Security Group management
- VPC Endpoint management
- Route 53 hosted zone management (if using domain)
- ACM certificate management (if using domain)
- Tagging resources

## Usage with Other Modules

### EKS Cluster

```hcl
module "vpc" {
  source = "path/to/vpc"
  # ... configuration ...
}

module "eks" {
  source = "path/to/eks"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  endpoint_public_access_cidrs = [
    module.vpc.allowlist_prefix_list_id_ipv4
  ]
}
```

### RDS Database

```hcl
module "vpc" {
  source = "path/to/vpc"
  # ... configuration ...
}

module "rds" {
  source = "path/to/rds"
  
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.database_subnet_ids
  security_group_id = module.vpc.database_security_group_id
}
```

### Using Private Hosted Zone for Internal Services

When you specify the `domain` variable, the module automatically creates both public and private Route53 hosted zones using the same domain (`{environment}.{domain}`). The private hosted zone is automatically associated with the VPC and allows you to create CNAME or ALIAS records for internal services like Redis, RDS, ElastiCache, etc. within the same domain namespace.

**Note**: Private and public hosted zones use the same domain name but are separate zones. The private zone is only accessible within the VPC, while the public zone is accessible from the internet.

```hcl
module "vpc" {
  source = "path/to/vpc"
  
  project     = "my-project"
  environment = "production"
  domain      = "example.com"
  
  # Both public and private hosted zones are automatically created
  # Private hosted zone is automatically associated with the VPC
}

# Example: Create CNAME record for Redis cluster
resource "aws_route53_record" "redis" {
  zone_id = module.vpc.private_hosted_zone_id
  name    = "redis"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.main.configuration_endpoint_address]
}

# Example: Create ALIAS record for RDS database
resource "aws_route53_record" "database" {
  zone_id = module.vpc.private_hosted_zone_id
  name    = "database"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.main.endpoint]
}

# Example: Create CNAME record for ElastiCache
resource "aws_route53_record" "cache" {
  zone_id = module.vpc.private_hosted_zone_id
  name    = "cache"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_cluster.main.cache_nodes[0].address]
}
```

After creating these records, you can access services using friendly names (within the VPC):
- `redis.production.example.com`
- `database.production.example.com`
- `cache.production.example.com`

## Post-Deployment Tasks

1. **Update EKS Cluster** (if applicable):
   - Use `allowlist_prefix_list_id_ipv4` output in EKS `endpoint_public_access_cidrs`

2. **Configure DNS** (if using domain):
   - Add NS records from `hosted_zone_name_servers` output to parent domain
   - See `zzz_hosted_zone_delegation_instructions` output for detailed steps
   - Use `hosted_zone_ns_records_formatted` for easy copy-paste
   - See [DNS Delegation](#dns-delegation) section below for detailed instructions

3. **Update Security Groups**:
   - Reference security group IDs in other resources (EC2, RDS, EKS, etc.)

## DNS Delegation

When using the `domain` variable, the module creates a Route53 hosted zone for `${environment}.${domain}` (e.g., `production.example.com`). To make this work, you need to delegate DNS management to Route53 by adding NS records in your parent domain's DNS provider.

### Quick Start

After deploying the VPC module, run:

```bash
# View formatted NS records
terraform output hosted_zone_ns_records_formatted

# View detailed instructions
terraform output zzz_hosted_zone_delegation_instructions

# View NS records list (for programmatic use)
terraform output hosted_zone_ns_records_list
```

### Using NS Records Outputs

The module provides multiple formats for NS records to suit different use cases:

1. **Formatted String** (`hosted_zone_ns_records_formatted`):
   ```bash
   terraform output hosted_zone_ns_records_formatted
   ```
   Outputs a formatted string ready for copy-paste.

2. **Cloudflare JSON** (`hosted_zone_ns_records_cloudflare`):
   ```bash
   terraform output hosted_zone_ns_records_cloudflare
   ```
   Outputs JSON format specifically for Cloudflare API.

3. **List Format** (`hosted_zone_ns_records_list`):
   ```bash
   terraform output hosted_zone_ns_records_list
   ```
   Outputs a simple list of name servers for programmatic use.

4. **Object Format** (`hosted_zone_ns_records`):
   ```bash
   terraform output hosted_zone_ns_records
   ```
   Outputs an object with type, name, TTL, and values.

### Cloudflare Instructions

1. Go to Cloudflare Dashboard → DNS → Records
2. Click "Add record"
3. Select Type: **NS**
4. Name: `{environment}` (e.g., `production`)
5. Content: Add each name server (one per record, or comma-separated if supported)
6. TTL: Auto (or 3600)
7. **⚠️ IMPORTANT**: Set Proxy status to **DNS only** (disable Cloudflare proxy)
8. Click "Save"
9. Repeat for all name servers (typically 4 NS records)

### GoDaddy Instructions

1. Go to GoDaddy DNS Management
2. Click "Add" to create a new record
3. Type: **NS**
4. Host: `{environment}` (e.g., `production`)
5. Points to: Add each name server (create separate records for each)
6. TTL: 1 hour
7. Click "Save"
8. Repeat for all name servers

### Namecheap Instructions

1. Go to Namecheap Domain List → Manage → Advanced DNS
2. Click "Add New Record"
3. Type: **NS Record**
4. Host: `{environment}` (e.g., `production`)
5. Value: Add each name server (one per record)
6. TTL: Automatic (or 3600)
7. Click "Save"
8. Repeat for all name servers

### Verification

After adding NS records, verify with:

```bash
# Quick check
dig NS ${environment}.${domain} +short

# Full verification
dig NS ${environment}.${domain}

# Expected output should show all name servers from hosted_zone_name_servers
```

### Important Notes

- ⚠️ **Add ALL NS records**: Route53 typically provides 4 name servers - add all of them
- ⚠️ **DNS Propagation**: Changes may take up to 48 hours to propagate globally
- ⚠️ **Cloudflare Proxy**: If using Cloudflare, set Proxy status to "DNS only" for NS records
- ⚠️ **Do NOT delete existing NS records** until new ones are verified and working
- ⚠️ **Parent Domain**: Add NS records in the parent domain (e.g., `example.com`), not the subdomain

### Using from Remote State

Other projects can reference NS records from VPC remote state:

```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"
  # ... config ...
}

# Get NS records
locals {
  ns_records = data.terraform_remote_state.vpc.outputs.hosted_zone_ns_records_list
}

# Use in other resources
output "dns_delegation_info" {
  value = {
    subdomain = data.terraform_remote_state.vpc.outputs.domain_name
    ns_records = data.terraform_remote_state.vpc.outputs.hosted_zone_ns_records_list
    instructions = data.terraform_remote_state.vpc.outputs.zzz_hosted_zone_delegation_instructions
  }
}
```

## Troubleshooting

### Common Issues

1. **CIDR Block Conflicts**: Ensure VPC CIDR doesn't overlap with existing VPCs or on-premises networks
2. **Availability Zone Limits**: Some regions have limited availability zones
3. **Security Group Rule Limits**: AWS limits security groups to 60 rules per direction
4. **NAT Gateway Costs**: NAT Gateways are charged per hour (~$32/month each)

## Contributing

Contributions are welcome! Please ensure:

1. Code follows Terraform best practices
2. All variables have descriptions
3. Examples are updated
4. Documentation is kept up to date

## License

This module is licensed under the Apache License 2.0. See [LICENSE](../LICENSE) for details.

## References

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
