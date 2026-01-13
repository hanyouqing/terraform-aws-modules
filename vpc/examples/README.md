# VPC Module Examples

This directory contains example configurations for the VPC module.

## Examples

### Basic Example (`basic/`)

A minimal VPC configuration suitable for testing environments:

- Single VPC with public, private, and database subnets
- Single NAT Gateway (cost-optimized)
- VPC Flow Logs enabled
- Multi-AZ deployment (3 availability zones)
- Basic security groups

**Usage:**
```bash
cd examples/basic
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

**Estimated Cost**: ~$40-50/month

### Complete Example (`complete/`)

A production-ready VPC configuration with all features:

- Multi-AZ VPC with public, private, and database subnets
- Multiple NAT Gateways (high availability)
- VPC Flow Logs enabled
- Managed Prefix List for allowlist (IPv4 and IPv6)
- Security groups (jump, public, private, database, VPC endpoints)
- Route 53 hosted zone (optional)
- ACM certificate (optional)
- VPC Endpoints (ECR, EKS, CloudWatch Logs, Secrets Manager, S3)

**Usage:**
```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values (especially allowlist_ipv4_blocks)
terraform init
terraform plan
terraform apply
```

**Estimated Cost**: ~$140-150/month (production) or ~$75-85/month (non-production with single NAT)

## Prerequisites

Before using these examples, ensure you have:

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.14 installed
3. **AWS Account** with sufficient permissions to create VPC resources
4. **Domain name** (optional, only if using Route 53 hosted zone in complete example)

## Required AWS Permissions

The AWS credentials used must have permissions for:

- VPC, Subnet, Route Table, Internet Gateway, NAT Gateway management
- VPC Flow Logs (including CloudWatch Logs and IAM role creation)
- RDS Subnet Group management
- Security Group management
- VPC Endpoint management
- Route 53 hosted zone management (if using domain)
- ACM certificate management (if using domain)
- Tagging resources

## Configuration

### Basic Example

The basic example requires minimal configuration:

- `region`: AWS region
- `project`: Project name
- `environment`: Environment name (testing, staging, production)
- `vpc_cidr`: CIDR block for VPC

### Complete Example

The complete example includes additional configuration:

- `allowlist_ipv4_blocks`: List of IPv4 CIDR blocks for Managed Prefix List
- `domain`: Base domain name (optional, for Route 53 hosted zone)
- `single_nat_gateway`: Set to `true` for cost optimization in non-production

## Post-Deployment

After deploying the VPC:

1. **Update EKS Cluster** (if applicable):
   - Use `allowlist_prefix_list_id_ipv4` output in EKS `endpoint_public_access_cidrs`

2. **Configure DNS** (if using domain):
   - Add NS records from `hosted_zone_name_servers` output to parent domain

3. **Use Security Groups**:
   - Reference security group IDs in other resources (EC2, RDS, EKS, etc.)

4. **Use Subnets**:
   - Reference subnet IDs in other resources (EKS, RDS, EC2, etc.)

## Cost Optimization

### For Non-Production Environments

- Set `single_nat_gateway = true` to save ~$64/month
- Disable unnecessary VPC endpoints
- Use smaller CIDR blocks

### For Production Environments

- Use multiple NAT Gateways for high availability
- Enable all VPC endpoints for security
- Use larger CIDR blocks for scalability

## Troubleshooting

### Common Issues

1. **CIDR Block Conflicts**: Ensure VPC CIDR doesn't overlap with existing VPCs or on-premises networks
2. **Availability Zone Limits**: Some regions have limited availability zones
3. **Security Group Rule Limits**: AWS limits security groups to 60 rules per direction
4. **NAT Gateway Costs**: NAT Gateways are charged per hour (~$32/month each)

### Getting Help

- Check the main [README.md](../README.md) for detailed documentation
- Review AWS VPC documentation for service-specific issues
- Check Terraform AWS provider documentation for resource-specific issues
