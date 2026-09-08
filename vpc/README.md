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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_acm_certificate.environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_ce_anomaly_monitor.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor) | resource |
| [aws_ce_anomaly_subscription.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_subscription) | resource |
| [aws_cloudwatch_log_group.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.nat_gateway_bandwidth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_default_network_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ec2_managed_prefix_list.allowlist_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_managed_prefix_list.allowlist_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route.peering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.jump](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.database_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.database_egress_to_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.database_ingress_from_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.database_ingress_from_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.jump_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.jump_egress_to_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.jump_ingress_ssh_from_allowlist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.private_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.private_egress_to_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.private_ingress_ssh_from_jump](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.public_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.public_egress_to_vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.public_ingress_allowlist_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.public_ingress_ssh_from_jump](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_endpoints_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_endpoints_ingress_from_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_endpoints_ingress_from_jump](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_endpoints_ingress_from_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_endpoints_ingress_from_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_peering_connection.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allowlist_ipv4_blocks"></a> [allowlist\_ipv4\_blocks](#input\_allowlist\_ipv4\_blocks) | List of IPv4 CIDR blocks to include in the Managed Prefix List allowlist | <pre>list(object({<br/>    cidr        = string<br/>    description = string<br/>  }))</pre> | `[]` | no |
| <a name="input_allowlist_ipv6_blocks"></a> [allowlist\_ipv6\_blocks](#input\_allowlist\_ipv6\_blocks) | List of IPv6 CIDR blocks to include in the Managed Prefix List allowlist | <pre>list(object({<br/>    cidr        = string<br/>    description = string<br/>  }))</pre> | `[]` | no |
| <a name="input_assign_ipv6_address_on_creation"></a> [assign\_ipv6\_address\_on\_creation](#input\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on subnet creation. Requires enable\_ipv6 = true | `bool` | `false` | no |
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | IAM role ARN to assume for cross-account access (optional) | `string` | `null` | no |
| <a name="input_assume_role_external_id"></a> [assume\_role\_external\_id](#input\_assume\_role\_external\_id) | External ID to use when assuming role (optional) | `string` | `null` | no |
| <a name="input_assume_role_session_name"></a> [assume\_role\_session\_name](#input\_assume\_role\_session\_name) | Session name to use when assuming role | `string` | `"terraform-vpc"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones. Must match the number of subnets in each tier. | `list(string)` | <pre>[<br/>  "us-east-1a",<br/>  "us-east-1b",<br/>  "us-east-1c"<br/>]</pre> | no |
| <a name="input_cloudwatch_alarm_sns_topic_arn"></a> [cloudwatch\_alarm\_sns\_topic\_arn](#input\_cloudwatch\_alarm\_sns\_topic\_arn) | SNS topic ARN for CloudWatch alarm notifications. Required if enable\_cloudwatch\_alarms = true or enable\_cost\_anomaly\_detection = true | `string` | `null` | no |
| <a name="input_cloudwatch_logs_encryption_enabled"></a> [cloudwatch\_logs\_encryption\_enabled](#input\_cloudwatch\_logs\_encryption\_enabled) | Enable encryption for CloudWatch Logs (KMS) | `bool` | `false` | no |
| <a name="input_cloudwatch_logs_kms_key_id"></a> [cloudwatch\_logs\_kms\_key\_id](#input\_cloudwatch\_logs\_kms\_key\_id) | KMS key ID for CloudWatch Logs encryption. Required if cloudwatch\_logs\_encryption\_enabled = true | `string` | `null` | no |
| <a name="input_code"></a> [code](#input\_code) | Code repository and path (e.g., 'reponame:path/to/terraform/vpc') | `string` | `""` | no |
| <a name="input_cost_anomaly_detection_monitor_name"></a> [cost\_anomaly\_detection\_monitor\_name](#input\_cost\_anomaly\_detection\_monitor\_name) | Name for the Cost Anomaly Detection monitor | `string` | `null` | no |
| <a name="input_cost_anomaly_detection_threshold"></a> [cost\_anomaly\_detection\_threshold](#input\_cost\_anomaly\_detection\_threshold) | Threshold percentage for cost anomaly detection (default: 50) | `number` | `50` | no |
| <a name="input_database_security_group_allowed_cidr_blocks"></a> [database\_security\_group\_allowed\_cidr\_blocks](#input\_database\_security\_group\_allowed\_cidr\_blocks) | CIDR blocks allowed to access database security group. Should typically be private subnet CIDRs. If empty, only private security group access is allowed. | `list(string)` | `[]` | no |
| <a name="input_database_security_group_allowed_ports"></a> [database\_security\_group\_allowed\_ports](#input\_database\_security\_group\_allowed\_ports) | Ports allowed for database security group ingress. Common database ports: 1433 (SQL Server), 3306 (MySQL), 5432 (PostgreSQL), 6379 (Redis), 27017 (MongoDB) | `list(number)` | <pre>[<br/>  1433,<br/>  3306,<br/>  5432,<br/>  6379,<br/>  27017<br/>]</pre> | no |
| <a name="input_database_subnet_ipv6_prefixes"></a> [database\_subnet\_ipv6\_prefixes](#input\_database\_subnet\_ipv6\_prefixes) | IPv6 CIDR blocks for database subnets. If not specified and enable\_ipv6 = true, will be calculated automatically from VPC IPv6 CIDR | `list(string)` | `[]` | no |
| <a name="input_database_subnet_newbits"></a> [database\_subnet\_newbits](#input\_database\_subnet\_newbits) | Number of additional bits for database subnet CIDR calculation. Used when enable\_auto\_cidr = true | `number` | `8` | no |
| <a name="input_database_subnet_offset"></a> [database\_subnet\_offset](#input\_database\_subnet\_offset) | Offset for database subnet CIDR calculation. Used when enable\_auto\_cidr = true | `number` | `128` | no |
| <a name="input_database_subnet_tags"></a> [database\_subnet\_tags](#input\_database\_subnet\_tags) | Additional tags to apply to database subnets | `map(string)` | `{}` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | CIDR blocks for database subnets. Must be within the VPC CIDR block. Count should match availability\_zones count. Can be empty if database subnets are not needed. | `list(string)` | <pre>[<br/>  "10.0.21.0/24",<br/>  "10.0.22.0/24",<br/>  "10.0.23.0/24"<br/>]</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Base domain name (e.g., example.com). When specified, creates both public and private Route53 hosted zones for {environment}.{domain}. The private hosted zone is automatically associated with the VPC. | `string` | `null` | no |
| <a name="input_enable_auto_cidr"></a> [enable\_auto\_cidr](#input\_enable\_auto\_cidr) | Enable automatic CIDR calculation for subnets from VPC CIDR | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_alarms"></a> [enable\_cloudwatch\_alarms](#input\_enable\_cloudwatch\_alarms) | Enable CloudWatch alarms for VPC resources | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_logs_endpoint"></a> [enable\_cloudwatch\_logs\_endpoint](#input\_enable\_cloudwatch\_logs\_endpoint) | Enable CloudWatch Logs VPC endpoint | `bool` | `true` | no |
| <a name="input_enable_cost_anomaly_detection"></a> [enable\_cost\_anomaly\_detection](#input\_enable\_cost\_anomaly\_detection) | Enable AWS Cost Anomaly Detection | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support in VPC | `bool` | `true` | no |
| <a name="input_enable_dynamodb_endpoint"></a> [enable\_dynamodb\_endpoint](#input\_enable\_dynamodb\_endpoint) | Enable DynamoDB Gateway VPC endpoint | `bool` | `false` | no |
| <a name="input_enable_ec2messages_endpoint"></a> [enable\_ec2messages\_endpoint](#input\_enable\_ec2messages\_endpoint) | Enable EC2 Messages VPC endpoint | `bool` | `false` | no |
| <a name="input_enable_ecr_api_endpoint"></a> [enable\_ecr\_api\_endpoint](#input\_enable\_ecr\_api\_endpoint) | Enable ECR API VPC endpoint | `bool` | `true` | no |
| <a name="input_enable_ecr_dkr_endpoint"></a> [enable\_ecr\_dkr\_endpoint](#input\_enable\_ecr\_dkr\_endpoint) | Enable ECR Docker API VPC endpoint | `bool` | `true` | no |
| <a name="input_enable_eks_endpoint"></a> [enable\_eks\_endpoint](#input\_enable\_eks\_endpoint) | Enable EKS API VPC endpoint | `bool` | `true` | no |
| <a name="input_enable_explicit_egress_rules"></a> [enable\_explicit\_egress\_rules](#input\_enable\_explicit\_egress\_rules) | Enable explicit egress rules for all security groups. When false, security groups allow all egress by default. | `bool` | `false` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Enable VPC Flow Logs | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable IPv6 support for VPC and subnets | `bool` | `false` | no |
| <a name="input_enable_ipv6_security_group_rules"></a> [enable\_ipv6\_security\_group\_rules](#input\_enable\_ipv6\_security\_group\_rules) | Enable IPv6 security group rules. Disable if you hit AWS security group rule limits (60 rules per direction) and don't need IPv6 support. | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| <a name="input_enable_network_acls"></a> [enable\_network\_acls](#input\_enable\_network\_acls) | Enable Network ACLs for defense in depth. Network ACLs provide an additional layer of security at the subnet level. | `bool` | `false` | no |
| <a name="input_enable_public_security_group"></a> [enable\_public\_security\_group](#input\_enable\_public\_security\_group) | Enable public security group with allowlist rules | `bool` | `true` | no |
| <a name="input_enable_s3_endpoint"></a> [enable\_s3\_endpoint](#input\_enable\_s3\_endpoint) | Enable S3 Gateway VPC endpoint | `bool` | `true` | no |
| <a name="input_enable_secretsmanager_endpoint"></a> [enable\_secretsmanager\_endpoint](#input\_enable\_secretsmanager\_endpoint) | Enable Secrets Manager VPC endpoint | `bool` | `true` | no |
| <a name="input_enable_ssm_endpoint"></a> [enable\_ssm\_endpoint](#input\_enable\_ssm\_endpoint) | Enable Systems Manager (SSM) VPC endpoint | `bool` | `false` | no |
| <a name="input_enable_ssmmessages_endpoint"></a> [enable\_ssmmessages\_endpoint](#input\_enable\_ssmmessages\_endpoint) | Enable Systems Manager Messages (SSM Messages) VPC endpoint | `bool` | `false` | no |
| <a name="input_enable_sts_endpoint"></a> [enable\_sts\_endpoint](#input\_enable\_sts\_endpoint) | Enable Security Token Service (STS) VPC endpoint | `bool` | `false` | no |
| <a name="input_enable_transit_gateway"></a> [enable\_transit\_gateway](#input\_enable\_transit\_gateway) | Enable Transit Gateway attachment | `bool` | `false` | no |
| <a name="input_enable_vpc_endpoints"></a> [enable\_vpc\_endpoints](#input\_enable\_vpc\_endpoints) | Enable VPC endpoints. When false, all VPC endpoints are disabled. | `bool` | `true` | no |
| <a name="input_enable_vpc_peering"></a> [enable\_vpc\_peering](#input\_enable\_vpc\_peering) | Enable VPC peering connections | `bool` | `false` | no |
| <a name="input_enable_vpn_gateway"></a> [enable\_vpn\_gateway](#input\_enable\_vpn\_gateway) | Enable VPN Gateway | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_flow_log_cloudwatch_log_group_retention_in_days"></a> [flow\_log\_cloudwatch\_log\_group\_retention\_in\_days](#input\_flow\_log\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the CloudWatch Log Group for VPC Flow Logs. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0 (never expire). | `number` | `7` | no |
| <a name="input_flow_log_destination_arn"></a> [flow\_log\_destination\_arn](#input\_flow\_log\_destination\_arn) | ARN of the destination for VPC Flow Logs (S3 bucket ARN or CloudWatch Logs log group ARN). Required if flow\_log\_destination\_type is 's3'. | `string` | `null` | no |
| <a name="input_flow_log_destination_type"></a> [flow\_log\_destination\_type](#input\_flow\_log\_destination\_type) | Type of flow log destination (cloud-watch-logs or s3) | `string` | `"cloud-watch-logs"` | no |
| <a name="input_flow_log_s3_encryption_enabled"></a> [flow\_log\_s3\_encryption\_enabled](#input\_flow\_log\_s3\_encryption\_enabled) | Enable encryption for S3 Flow Logs destination | `bool` | `true` | no |
| <a name="input_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#input\_ipv6\_cidr\_block) | IPv6 CIDR block for VPC. If not specified, AWS will assign one automatically. Requires enable\_ipv6 = true. Note: In AWS provider 6.28+, if specified, ipv6\_ipam\_pool\_id must also be provided. | `string` | `null` | no |
| <a name="input_nat_gateway_bandwidth_threshold"></a> [nat\_gateway\_bandwidth\_threshold](#input\_nat\_gateway\_bandwidth\_threshold) | Bandwidth threshold in bytes for NAT Gateway alarm (default: 1GB = 1073741824) | `number` | `1073741824` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the resources | `string` | `""` | no |
| <a name="input_private_subnet_ipv6_prefixes"></a> [private\_subnet\_ipv6\_prefixes](#input\_private\_subnet\_ipv6\_prefixes) | IPv6 CIDR blocks for private subnets. If not specified and enable\_ipv6 = true, will be calculated automatically from VPC IPv6 CIDR | `list(string)` | `[]` | no |
| <a name="input_private_subnet_newbits"></a> [private\_subnet\_newbits](#input\_private\_subnet\_newbits) | Number of additional bits for private subnet CIDR calculation. Used when enable\_auto\_cidr = true | `number` | `8` | no |
| <a name="input_private_subnet_offset"></a> [private\_subnet\_offset](#input\_private\_subnet\_offset) | Offset for private subnet CIDR calculation. Used when enable\_auto\_cidr = true | `number` | `64` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Additional tags to apply to private subnets | `map(string)` | `{}` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | CIDR blocks for private subnets. Must be within the VPC CIDR block. Count should match availability\_zones count. | `list(string)` | <pre>[<br/>  "10.0.11.0/24",<br/>  "10.0.12.0/24",<br/>  "10.0.13.0/24"<br/>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | `""` | no |
| <a name="input_public_security_group_allowed_tcp_ports"></a> [public\_security\_group\_allowed\_tcp\_ports](#input\_public\_security\_group\_allowed\_tcp\_ports) | List of TCP ports to allow from allowlist Managed Prefix List (deprecated: all ports 0-65535 are now allowed to reduce security group rule count) | `list(number)` | <pre>[<br/>  22,<br/>  80,<br/>  443<br/>]</pre> | no |
| <a name="input_public_security_group_allowed_udp_ports"></a> [public\_security\_group\_allowed\_udp\_ports](#input\_public\_security\_group\_allowed\_udp\_ports) | List of UDP ports to allow from allowlist Managed Prefix List (deprecated: all ports 0-65535 are now allowed to reduce security group rule count) | `list(number)` | `[]` | no |
| <a name="input_public_security_group_allowlist_enabled"></a> [public\_security\_group\_allowlist\_enabled](#input\_public\_security\_group\_allowlist\_enabled) | Enable allowlist rules for public security group. When enabled, only allowlist IPs can access public resources. | `bool` | `false` | no |
| <a name="input_public_subnet_ipv6_prefixes"></a> [public\_subnet\_ipv6\_prefixes](#input\_public\_subnet\_ipv6\_prefixes) | IPv6 CIDR blocks for public subnets. If not specified and enable\_ipv6 = true, will be calculated automatically from VPC IPv6 CIDR | `list(string)` | `[]` | no |
| <a name="input_public_subnet_newbits"></a> [public\_subnet\_newbits](#input\_public\_subnet\_newbits) | Number of additional bits for public subnet CIDR calculation. Used when enable\_auto\_cidr = true | `number` | `8` | no |
| <a name="input_public_subnet_offset"></a> [public\_subnet\_offset](#input\_public\_subnet\_offset) | Offset for public subnet CIDR calculation. Used when enable\_auto\_cidr = true | `number` | `0` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Additional tags to apply to public subnets | `map(string)` | `{}` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | CIDR blocks for public subnets. Must be within the VPC CIDR block. | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_restrict_default_security_group"></a> [restrict\_default\_security\_group](#input\_restrict\_default\_security\_group) | Restrict default security group to deny all traffic. This is a security best practice. | `bool` | `true` | no |
| <a name="input_security_group_egress_cidr_blocks"></a> [security\_group\_egress\_cidr\_blocks](#input\_security\_group\_egress\_cidr\_blocks) | CIDR blocks allowed for security group egress rules. Used when enable\_explicit\_egress\_rules = true | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Use single NAT Gateway for cost optimization (testing environment) | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_transit_gateway_dns_support"></a> [transit\_gateway\_dns\_support](#input\_transit\_gateway\_dns\_support) | Enable DNS support for Transit Gateway attachment | `bool` | `true` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | ID of the Transit Gateway to attach to. Required if enable\_transit\_gateway = true | `string` | `null` | no |
| <a name="input_transit_gateway_ipv6_support"></a> [transit\_gateway\_ipv6\_support](#input\_transit\_gateway\_ipv6\_support) | Enable IPv6 support for Transit Gateway attachment | `bool` | `false` | no |
| <a name="input_transit_gateway_routes"></a> [transit\_gateway\_routes](#input\_transit\_gateway\_routes) | Routes to add for Transit Gateway. Format: { route\_table\_id => cidr\_block } | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC. For production environments, consider using a larger CIDR (e.g., /14 or /12) for scalability. For non-production, /16 is typically sufficient. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_endpoint_policy_enabled"></a> [vpc\_endpoint\_policy\_enabled](#input\_vpc\_endpoint\_policy\_enabled) | Enable VPC endpoint policies for access control. When enabled, endpoints will have restrictive policies. | `bool` | `false` | no |
| <a name="input_vpc_peering_connections"></a> [vpc\_peering\_connections](#input\_vpc\_peering\_connections) | List of VPC peering connections to create | <pre>list(object({<br/>    peer_vpc_id     = string<br/>    peer_region     = optional(string, null)<br/>    peer_owner_id   = optional(string, null)<br/>    auto_accept     = optional(bool, false)<br/>    peer_cidr_block = optional(string, null)<br/>    tags            = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_vpc_peering_routes"></a> [vpc\_peering\_routes](#input\_vpc\_peering\_routes) | Routes to add for VPC peering connections. Format: { route\_key => { route\_table\_id = "rtb-xxx", destination\_cidr\_block = "10.1.0.0/16", peering\_connection\_key = "vpc-xxx-0" } } | <pre>map(object({<br/>    route_table_id         = string<br/>    destination_cidr_block = string<br/>    peering_connection_key = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM certificate for the environment domain |
| <a name="output_acm_certificate_domain_name"></a> [acm\_certificate\_domain\_name](#output\_acm\_certificate\_domain\_name) | Domain name of the ACM certificate |
| <a name="output_acm_certificate_id"></a> [acm\_certificate\_id](#output\_acm\_certificate\_id) | ID of the ACM certificate (certificate ARN without the 'arn:aws:acm:region:account:certificate/' prefix) |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status) | Status of the ACM certificate validation (certificate ARN if validated, null otherwise) |
| <a name="output_acm_certificate_subject_alternative_names"></a> [acm\_certificate\_subject\_alternative\_names](#output\_acm\_certificate\_subject\_alternative\_names) | List of subject alternative names (SANs) for the ACM certificate |
| <a name="output_acm_certificate_validation_method"></a> [acm\_certificate\_validation\_method](#output\_acm\_certificate\_validation\_method) | Validation method used for the ACM certificate (DNS or EMAIL) |
| <a name="output_acm_certificate_validation_record_fqdns"></a> [acm\_certificate\_validation\_record\_fqdns](#output\_acm\_certificate\_validation\_record\_fqdns) | List of FQDNs for DNS validation records |
| <a name="output_allowlist_prefix_list_arn_ipv4"></a> [allowlist\_prefix\_list\_arn\_ipv4](#output\_allowlist\_prefix\_list\_arn\_ipv4) | ARN of the IPv4 Managed Prefix List for allowlist |
| <a name="output_allowlist_prefix_list_arn_ipv6"></a> [allowlist\_prefix\_list\_arn\_ipv6](#output\_allowlist\_prefix\_list\_arn\_ipv6) | ARN of the IPv6 Managed Prefix List for allowlist |
| <a name="output_allowlist_prefix_list_arns_map"></a> [allowlist\_prefix\_list\_arns\_map](#output\_allowlist\_prefix\_list\_arns\_map) | Map of allowlist prefix list ARNs by name (format: {name => arn}) |
| <a name="output_allowlist_prefix_list_id_ipv4"></a> [allowlist\_prefix\_list\_id\_ipv4](#output\_allowlist\_prefix\_list\_id\_ipv4) | ID of the IPv4 Managed Prefix List for allowlist |
| <a name="output_allowlist_prefix_list_id_ipv6"></a> [allowlist\_prefix\_list\_id\_ipv6](#output\_allowlist\_prefix\_list\_id\_ipv6) | ID of the IPv6 Managed Prefix List for allowlist |
| <a name="output_allowlist_prefix_list_ids_map"></a> [allowlist\_prefix\_list\_ids\_map](#output\_allowlist\_prefix\_list\_ids\_map) | Map of allowlist prefix list IDs by name (format: {name => id}) |
| <a name="output_allowlist_prefix_list_name_ipv4"></a> [allowlist\_prefix\_list\_name\_ipv4](#output\_allowlist\_prefix\_list\_name\_ipv4) | Name of the IPv4 Managed Prefix List for allowlist |
| <a name="output_allowlist_prefix_list_name_ipv6"></a> [allowlist\_prefix\_list\_name\_ipv6](#output\_allowlist\_prefix\_list\_name\_ipv6) | Name of the IPv6 Managed Prefix List for allowlist |
| <a name="output_base_domain"></a> [base\_domain](#output\_base\_domain) | Base domain name (e.g., example.com) |
| <a name="output_cloudwatch_alarm_arns"></a> [cloudwatch\_alarm\_arns](#output\_cloudwatch\_alarm\_arns) | ARNs of the CloudWatch alarms |
| <a name="output_cloudwatch_logs_endpoint_arn"></a> [cloudwatch\_logs\_endpoint\_arn](#output\_cloudwatch\_logs\_endpoint\_arn) | ARN of the CloudWatch Logs VPC endpoint |
| <a name="output_cloudwatch_logs_endpoint_dns_entry"></a> [cloudwatch\_logs\_endpoint\_dns\_entry](#output\_cloudwatch\_logs\_endpoint\_dns\_entry) | DNS entries for the CloudWatch Logs VPC endpoint |
| <a name="output_cloudwatch_logs_endpoint_id"></a> [cloudwatch\_logs\_endpoint\_id](#output\_cloudwatch\_logs\_endpoint\_id) | ID of the CloudWatch Logs VPC endpoint |
| <a name="output_cost_anomaly_monitor_arn"></a> [cost\_anomaly\_monitor\_arn](#output\_cost\_anomaly\_monitor\_arn) | ARN of the Cost Anomaly Detection monitor |
| <a name="output_cost_anomaly_subscription_arn"></a> [cost\_anomaly\_subscription\_arn](#output\_cost\_anomaly\_subscription\_arn) | ARN of the Cost Anomaly Detection subscription |
| <a name="output_database_route_table_ids"></a> [database\_route\_table\_ids](#output\_database\_route\_table\_ids) | IDs of the database route tables |
| <a name="output_database_security_group_arn"></a> [database\_security\_group\_arn](#output\_database\_security\_group\_arn) | ARN of the database security group |
| <a name="output_database_security_group_id"></a> [database\_security\_group\_id](#output\_database\_security\_group\_id) | ID of the database security group |
| <a name="output_database_subnet_cidrs"></a> [database\_subnet\_cidrs](#output\_database\_subnet\_cidrs) | CIDR blocks of the database subnets |
| <a name="output_database_subnet_group_id"></a> [database\_subnet\_group\_id](#output\_database\_subnet\_group\_id) | ID of the database subnet group (null if no database subnets) |
| <a name="output_database_subnet_ids"></a> [database\_subnet\_ids](#output\_database\_subnet\_ids) | IDs of the database subnets (list format, for backward compatibility) |
| <a name="output_database_subnet_ids_map"></a> [database\_subnet\_ids\_map](#output\_database\_subnet\_ids\_map) | Map of database subnet IDs by name (format: {name => id}) |
| <a name="output_database_subnet_ipv6_cidr_blocks"></a> [database\_subnet\_ipv6\_cidr\_blocks](#output\_database\_subnet\_ipv6\_cidr\_blocks) | IPv6 CIDR blocks of the database subnets |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | ID of the default security group (restricted if restrict\_default\_security\_group = true) |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Full domain name for the environment (e.g., production.example.com) |
| <a name="output_dynamodb_endpoint_arn"></a> [dynamodb\_endpoint\_arn](#output\_dynamodb\_endpoint\_arn) | ARN of the DynamoDB Gateway VPC endpoint |
| <a name="output_dynamodb_endpoint_id"></a> [dynamodb\_endpoint\_id](#output\_dynamodb\_endpoint\_id) | ID of the DynamoDB Gateway VPC endpoint |
| <a name="output_dynamodb_endpoint_prefix_list_id"></a> [dynamodb\_endpoint\_prefix\_list\_id](#output\_dynamodb\_endpoint\_prefix\_list\_id) | Prefix list ID of the DynamoDB Gateway VPC endpoint |
| <a name="output_ecr_api_endpoint_arn"></a> [ecr\_api\_endpoint\_arn](#output\_ecr\_api\_endpoint\_arn) | ARN of the ECR API VPC endpoint |
| <a name="output_ecr_api_endpoint_dns_entry"></a> [ecr\_api\_endpoint\_dns\_entry](#output\_ecr\_api\_endpoint\_dns\_entry) | DNS entries for the ECR API VPC endpoint |
| <a name="output_ecr_api_endpoint_id"></a> [ecr\_api\_endpoint\_id](#output\_ecr\_api\_endpoint\_id) | ID of the ECR API VPC endpoint |
| <a name="output_ecr_dkr_endpoint_arn"></a> [ecr\_dkr\_endpoint\_arn](#output\_ecr\_dkr\_endpoint\_arn) | ARN of the ECR Docker API VPC endpoint |
| <a name="output_ecr_dkr_endpoint_dns_entry"></a> [ecr\_dkr\_endpoint\_dns\_entry](#output\_ecr\_dkr\_endpoint\_dns\_entry) | DNS entries for the ECR Docker API VPC endpoint |
| <a name="output_ecr_dkr_endpoint_id"></a> [ecr\_dkr\_endpoint\_id](#output\_ecr\_dkr\_endpoint\_id) | ID of the ECR Docker API VPC endpoint |
| <a name="output_eks_endpoint_arn"></a> [eks\_endpoint\_arn](#output\_eks\_endpoint\_arn) | ARN of the EKS API VPC endpoint |
| <a name="output_eks_endpoint_dns_entry"></a> [eks\_endpoint\_dns\_entry](#output\_eks\_endpoint\_dns\_entry) | DNS entries for the EKS API VPC endpoint |
| <a name="output_eks_endpoint_id"></a> [eks\_endpoint\_id](#output\_eks\_endpoint\_id) | ID of the EKS API VPC endpoint |
| <a name="output_gateway_endpoints"></a> [gateway\_endpoints](#output\_gateway\_endpoints) | Map of all gateway VPC endpoints (S3) |
| <a name="output_hosted_zone_arn"></a> [hosted\_zone\_arn](#output\_hosted\_zone\_arn) | ARN of the Route 53 hosted zone |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | ID of the Route 53 hosted zone |
| <a name="output_hosted_zone_name"></a> [hosted\_zone\_name](#output\_hosted\_zone\_name) | Name of the Route 53 hosted zone |
| <a name="output_hosted_zone_name_servers"></a> [hosted\_zone\_name\_servers](#output\_hosted\_zone\_name\_servers) | Name servers for the Route 53 hosted zone (use these to configure NS records in parent domain) |
| <a name="output_hosted_zone_name_servers_list"></a> [hosted\_zone\_name\_servers\_list](#output\_hosted\_zone\_name\_servers\_list) | List of name servers for easy copy-paste (one per line) |
| <a name="output_hosted_zone_ns_records"></a> [hosted\_zone\_ns\_records](#output\_hosted\_zone\_ns\_records) | NS records formatted for DNS providers (e.g., Cloudflare). Add these NS records in the parent domain. |
| <a name="output_hosted_zone_ns_records_cloudflare"></a> [hosted\_zone\_ns\_records\_cloudflare](#output\_hosted\_zone\_ns\_records\_cloudflare) | NS records formatted specifically for Cloudflare DNS (JSON format) |
| <a name="output_hosted_zone_ns_records_formatted"></a> [hosted\_zone\_ns\_records\_formatted](#output\_hosted\_zone\_ns\_records\_formatted) | NS records in a formatted string for easy copy-paste to DNS providers |
| <a name="output_hosted_zone_ns_records_list"></a> [hosted\_zone\_ns\_records\_list](#output\_hosted\_zone\_ns\_records\_list) | List of NS record values (name servers) for programmatic use |
| <a name="output_interface_endpoints"></a> [interface\_endpoints](#output\_interface\_endpoints) | Map of all interface VPC endpoints (ECR DKR, ECR API, EKS, CloudWatch Logs, Secrets Manager) |
| <a name="output_internet_gateway_arn"></a> [internet\_gateway\_arn](#output\_internet\_gateway\_arn) | ARN of the Internet Gateway |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID of the Internet Gateway |
| <a name="output_jump_security_group_arn"></a> [jump\_security\_group\_arn](#output\_jump\_security\_group\_arn) | ARN of the jump security group |
| <a name="output_jump_security_group_id"></a> [jump\_security\_group\_id](#output\_jump\_security\_group\_id) | ID of the jump security group |
| <a name="output_jump_security_group_name"></a> [jump\_security\_group\_name](#output\_jump\_security\_group\_name) | Name of the jump security group |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | IDs of the NAT Gateways (list format, for backward compatibility) |
| <a name="output_nat_gateway_ids_map"></a> [nat\_gateway\_ids\_map](#output\_nat\_gateway\_ids\_map) | Map of NAT Gateway IDs by name (format: {name => id}) |
| <a name="output_nat_gateway_public_ips"></a> [nat\_gateway\_public\_ips](#output\_nat\_gateway\_public\_ips) | Map of NAT Gateway public IPs by name (format: {name => public\_ip}) |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | Public IPs of the NAT Gateways (list format, for backward compatibility) |
| <a name="output_nat_public_ips_map"></a> [nat\_public\_ips\_map](#output\_nat\_public\_ips\_map) | Map of NAT Gateway public IPs by name (format: {name => public\_ip}) |
| <a name="output_network_acl_ids"></a> [network\_acl\_ids](#output\_network\_acl\_ids) | IDs of the Network ACLs (if enabled) |
| <a name="output_private_hosted_zone_arn"></a> [private\_hosted\_zone\_arn](#output\_private\_hosted\_zone\_arn) | ARN of the Route 53 private hosted zone ({environment}.{domain}) for internal services. Automatically created when domain is specified. |
| <a name="output_private_hosted_zone_id"></a> [private\_hosted\_zone\_id](#output\_private\_hosted\_zone\_id) | ID of the Route 53 private hosted zone ({environment}.{domain}) for internal services like Redis, Database, etc. Uses the same domain as public hosted zone. Automatically created when domain is specified. |
| <a name="output_private_hosted_zone_name"></a> [private\_hosted\_zone\_name](#output\_private\_hosted\_zone\_name) | Name of the Route 53 private hosted zone ({environment}.{domain}) for internal services. Uses the same domain as public hosted zone. Automatically created when domain is specified. |
| <a name="output_private_hosted_zone_name_servers"></a> [private\_hosted\_zone\_name\_servers](#output\_private\_hosted\_zone\_name\_servers) | Name servers for the Route 53 private hosted zone ({environment}.{domain}) for internal services. Automatically created when domain is specified. |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of the private route tables |
| <a name="output_private_security_group_arn"></a> [private\_security\_group\_arn](#output\_private\_security\_group\_arn) | ARN of the private security group |
| <a name="output_private_security_group_id"></a> [private\_security\_group\_id](#output\_private\_security\_group\_id) | ID of the private security group |
| <a name="output_private_security_group_name"></a> [private\_security\_group\_name](#output\_private\_security\_group\_name) | Name of the private security group |
| <a name="output_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#output\_private\_subnet\_cidrs) | CIDR blocks of the private subnets |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets (list format, for backward compatibility) |
| <a name="output_private_subnet_ids_map"></a> [private\_subnet\_ids\_map](#output\_private\_subnet\_ids\_map) | Map of private subnet IDs by name (format: {name => id}) |
| <a name="output_private_subnet_ipv6_cidr_blocks"></a> [private\_subnet\_ipv6\_cidr\_blocks](#output\_private\_subnet\_ipv6\_cidr\_blocks) | IPv6 CIDR blocks of the private subnets |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | IDs of the public route tables |
| <a name="output_public_security_group_arn"></a> [public\_security\_group\_arn](#output\_public\_security\_group\_arn) | ARN of the public security group |
| <a name="output_public_security_group_id"></a> [public\_security\_group\_id](#output\_public\_security\_group\_id) | ID of the public security group |
| <a name="output_public_security_group_name"></a> [public\_security\_group\_name](#output\_public\_security\_group\_name) | Name of the public security group |
| <a name="output_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#output\_public\_subnet\_cidrs) | CIDR blocks of the public subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets (list format, for backward compatibility) |
| <a name="output_public_subnet_ids_map"></a> [public\_subnet\_ids\_map](#output\_public\_subnet\_ids\_map) | Map of public subnet IDs by name (format: {name => id}) |
| <a name="output_public_subnet_ipv6_cidr_blocks"></a> [public\_subnet\_ipv6\_cidr\_blocks](#output\_public\_subnet\_ipv6\_cidr\_blocks) | IPv6 CIDR blocks of the public subnets |
| <a name="output_route53_zone_arns_map"></a> [route53\_zone\_arns\_map](#output\_route53\_zone\_arns\_map) | Map of Route53 hosted zone ARNs by name (format: {name => arn}). Includes both public and private hosted zones when domain is specified. |
| <a name="output_route53_zone_ids_map"></a> [route53\_zone\_ids\_map](#output\_route53\_zone\_ids\_map) | Map of Route53 hosted zone IDs by name (format: {name => zone\_id}). Includes both public and private hosted zones when domain is specified. |
| <a name="output_route53_zone_name_servers_map"></a> [route53\_zone\_name\_servers\_map](#output\_route53\_zone\_name\_servers\_map) | Map of Route53 hosted zone name servers by name (format: {name => [name\_servers]}). Includes both public and private hosted zones when domain is specified. |
| <a name="output_s3_endpoint_arn"></a> [s3\_endpoint\_arn](#output\_s3\_endpoint\_arn) | ARN of the S3 VPC endpoint |
| <a name="output_s3_endpoint_id"></a> [s3\_endpoint\_id](#output\_s3\_endpoint\_id) | ID of the S3 VPC endpoint |
| <a name="output_s3_endpoint_prefix_list_id"></a> [s3\_endpoint\_prefix\_list\_id](#output\_s3\_endpoint\_prefix\_list\_id) | Prefix list ID of the S3 VPC endpoint |
| <a name="output_secretsmanager_endpoint_arn"></a> [secretsmanager\_endpoint\_arn](#output\_secretsmanager\_endpoint\_arn) | ARN of the Secrets Manager VPC endpoint |
| <a name="output_secretsmanager_endpoint_dns_entry"></a> [secretsmanager\_endpoint\_dns\_entry](#output\_secretsmanager\_endpoint\_dns\_entry) | DNS entries for the Secrets Manager VPC endpoint |
| <a name="output_secretsmanager_endpoint_id"></a> [secretsmanager\_endpoint\_id](#output\_secretsmanager\_endpoint\_id) | ID of the Secrets Manager VPC endpoint |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | IDs of all security groups (list format, for backward compatibility) |
| <a name="output_security_group_ids_map"></a> [security\_group\_ids\_map](#output\_security\_group\_ids\_map) | Map of all security groups (format: {jump => id, public => id, private => id, database => id}) |
| <a name="output_security_group_rule_counts"></a> [security\_group\_rule\_counts](#output\_security\_group\_rule\_counts) | Security group rule counts for validation (AWS limit: 60 rules per direction) |
| <a name="output_ssm_endpoint_arn"></a> [ssm\_endpoint\_arn](#output\_ssm\_endpoint\_arn) | ARN of the SSM VPC endpoint |
| <a name="output_ssm_endpoint_id"></a> [ssm\_endpoint\_id](#output\_ssm\_endpoint\_id) | ID of the SSM VPC endpoint |
| <a name="output_sts_endpoint_arn"></a> [sts\_endpoint\_arn](#output\_sts\_endpoint\_arn) | ARN of the STS VPC endpoint |
| <a name="output_sts_endpoint_id"></a> [sts\_endpoint\_id](#output\_sts\_endpoint\_id) | ID of the STS VPC endpoint |
| <a name="output_transit_gateway_attachment_arn"></a> [transit\_gateway\_attachment\_arn](#output\_transit\_gateway\_attachment\_arn) | ARN of the Transit Gateway VPC attachment |
| <a name="output_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#output\_transit\_gateway\_attachment\_id) | ID of the Transit Gateway VPC attachment |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | CIDR block of the VPC |
| <a name="output_vpc_cidr_block_associations"></a> [vpc\_cidr\_block\_associations](#output\_vpc\_cidr\_block\_associations) | CIDR block associations for the VPC |
| <a name="output_vpc_default_route_table_id"></a> [vpc\_default\_route\_table\_id](#output\_vpc\_default\_route\_table\_id) | ID of the default route table for the VPC |
| <a name="output_vpc_default_security_group_id"></a> [vpc\_default\_security\_group\_id](#output\_vpc\_default\_security\_group\_id) | ID of the default security group for the VPC |
| <a name="output_vpc_endpoints_security_group_arn"></a> [vpc\_endpoints\_security\_group\_arn](#output\_vpc\_endpoints\_security\_group\_arn) | ARN of the VPC endpoints security group |
| <a name="output_vpc_endpoints_security_group_id"></a> [vpc\_endpoints\_security\_group\_id](#output\_vpc\_endpoints\_security\_group\_id) | ID of the VPC endpoints security group |
| <a name="output_vpc_flow_log_cloudwatch_log_group_arn"></a> [vpc\_flow\_log\_cloudwatch\_log\_group\_arn](#output\_vpc\_flow\_log\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch Log Group for VPC Flow Logs |
| <a name="output_vpc_flow_log_cloudwatch_log_group_name"></a> [vpc\_flow\_log\_cloudwatch\_log\_group\_name](#output\_vpc\_flow\_log\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group for VPC Flow Logs |
| <a name="output_vpc_flow_log_id"></a> [vpc\_flow\_log\_id](#output\_vpc\_flow\_log\_id) | ID of the VPC Flow Log |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
| <a name="output_vpc_ipv6_association_id"></a> [vpc\_ipv6\_association\_id](#output\_vpc\_ipv6\_association\_id) | IPv6 association ID for the VPC (if enabled) |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | IPv6 CIDR block for the VPC (if enabled) |
| <a name="output_vpc_main_route_table_id"></a> [vpc\_main\_route\_table\_id](#output\_vpc\_main\_route\_table\_id) | ID of the main route table for the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of the VPC |
| <a name="output_vpc_peering_connection_arns"></a> [vpc\_peering\_connection\_arns](#output\_vpc\_peering\_connection\_arns) | ARNs of the VPC peering connections |
| <a name="output_vpc_peering_connection_ids"></a> [vpc\_peering\_connection\_ids](#output\_vpc\_peering\_connection\_ids) | IDs of the VPC peering connections |
| <a name="output_zzz_allowlist_update_reminder"></a> [zzz\_allowlist\_update\_reminder](#output\_zzz\_allowlist\_update\_reminder) | ⚠️ REMINDER: Important tasks after VPC deployment |
| <a name="output_zzz_hosted_zone_delegation_instructions"></a> [zzz\_hosted\_zone\_delegation\_instructions](#output\_zzz\_hosted\_zone\_delegation\_instructions) | Instructions for delegating the subdomain to Route53 |
| <a name="output_zzz_reminders"></a> [zzz\_reminders](#output\_zzz\_reminders) | 📝 REMINDER: Complete examples for using VPC outputs in EC2, RDS, Redis, and other resources |
<!-- END_TF_DOCS -->
