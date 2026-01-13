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
- ✅ Route 53 hosted zone (optional)
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
| domain | Base domain name for Route 53 hosted zone | `string` | `null` | no |
| enable_vpc_endpoints | Enable VPC endpoints | `bool` | `true` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

See [variables.tf](./variables.tf) for the complete list of available variables.

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_name | Name of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| public_subnet_ids | IDs of the public subnets |
| private_subnet_ids | IDs of the private subnets |
| database_subnet_ids | IDs of the database subnets |
| nat_gateway_ids | IDs of the NAT Gateways |
| internet_gateway_id | ID of the Internet Gateway |
| allowlist_prefix_list_id_ipv4 | ID of the IPv4 Managed Prefix List |
| jump_security_group_id | ID of the jump security group |
| public_security_group_id | ID of the public security group |
| private_security_group_id | ID of the private security group |
| database_security_group_id | ID of the database security group |
| vpc_endpoints_security_group_id | ID of the VPC endpoints security group |
| hosted_zone_id | ID of the Route 53 hosted zone (if domain is set) |
| acm_certificate_arn | ARN of the ACM certificate (if domain is set) |

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

## Post-Deployment Tasks

1. **Update EKS Cluster** (if applicable):
   - Use `allowlist_prefix_list_id_ipv4` output in EKS `endpoint_public_access_cidrs`

2. **Configure DNS** (if using domain):
   - Add NS records from `hosted_zone_name_servers` output to parent domain

3. **Update Security Groups**:
   - Reference security group IDs in other resources (EC2, RDS, EKS, etc.)

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
