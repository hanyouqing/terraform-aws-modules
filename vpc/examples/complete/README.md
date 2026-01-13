# Complete VPC Example

This example demonstrates a production-ready VPC configuration with all features enabled.

## Features

- Multi-AZ VPC with public, private, and database subnets
- Multiple NAT Gateways (high availability for production)
- VPC Flow Logs enabled
- Managed Prefix List for allowlist (IPv4 and IPv6)
- Security groups (jump, public, private, database, VPC endpoints)
- Route 53 hosted zone (optional)
- ACM certificate (optional, requires domain)
- VPC Endpoints:
  - ECR Docker API
  - ECR API
  - EKS API
  - CloudWatch Logs
  - Secrets Manager
  - S3 Gateway

## Usage

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values:
   - Update `allowlist_ipv4_blocks` with your office/VPN IPs
   - Set `domain` if you want Route 53 hosted zone
   - Adjust CIDR blocks if needed

3. Initialize Terraform:
```bash
terraform init
```

4. Review the plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

## Configuration

### Required Configuration

- `region`: AWS region
- `project`: Project name
- `environment`: Environment name (testing, staging, production)
- `vpc_cidr`: CIDR block for VPC
- `allowlist_ipv4_blocks`: Your office/VPN IP addresses

### Optional Configuration

- `domain`: Base domain name for Route 53 hosted zone
- `single_nat_gateway`: Set to `true` for cost optimization (non-production)

## Cost Considerations

This complete example includes all features for production-ready deployments.

### Monthly Cost Breakdown

#### Production Configuration (Multi-AZ NAT Gateways)

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| **NAT Gateways** | 3 (one per AZ) | $0.045/hour | ~$98.55 |
| **NAT Gateway Data Processing** | ~10 GB | $0.045/GB | ~$0.45 |
| **VPC Endpoints (Interface)** | 5 | $0.01/hour + $0.01/GB | ~$36.50 |
| - ECR DKR | 1 | $0.01/hour | ~$7.30 |
| - ECR API | 1 | $0.01/hour | ~$7.30 |
| - EKS | 1 | $0.01/hour | ~$7.30 |
| - CloudWatch Logs | 1 | $0.01/hour | ~$7.30 |
| - Secrets Manager | 1 | $0.01/hour | ~$7.30 |
| **VPC Endpoint (Gateway - S3)** | 1 | Free | $0 |
| **VPC Flow Logs** | 1 | Variable | ~$10-15 |
| **Route 53 Hosted Zone** | 1 | $0.50/month | ~$0.50 |
| **Route 53 DNS Queries** | ~1M queries | $0.40/million | ~$0.40 |
| **ACM Certificate** | 1 | Free | $0 |
| **Managed Prefix List** | 1-2 | Free | $0 |
| **VPC** | 1 | Free | $0 |
| **Subnets** | 9 | Free | $0 |
| **Route Tables** | 7 | Free | $0 |
| **Internet Gateway** | 1 | Free | $0 |
| **Security Groups** | 5 | Free | $0 |
| **Elastic IPs** | 3 (for NAT) | Free (when attached) | $0 |

**Total Estimated Monthly Cost (Production)**: ~$145-150/month

#### Non-Production Configuration (Single NAT Gateway)

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| **NAT Gateway** | 1 | $0.045/hour | ~$32.85 |
| **NAT Gateway Data Processing** | ~5 GB | $0.045/GB | ~$0.23 |
| **VPC Endpoints (Interface)** | 5 | $0.01/hour + $0.01/GB | ~$36.50 |
| **VPC Endpoint (Gateway - S3)** | 1 | Free | $0 |
| **VPC Flow Logs** | 1 | Variable | ~$5-10 |
| **Route 53 Hosted Zone** | 1 | $0.50/month | ~$0.50 |
| **Route 53 DNS Queries** | ~500K queries | $0.40/million | ~$0.20 |
| **ACM Certificate** | 1 | Free | $0 |
| **Managed Prefix List** | 1-2 | Free | $0 |
| **Other Resources** | - | Free | $0 |

**Total Estimated Monthly Cost (Non-Production)**: ~$75-80/month

### Detailed Cost Breakdown

#### NAT Gateway Costs
- **Hourly Charge**: $0.045/hour per NAT Gateway
  - Production (3 NATs): $0.045 × 3 × 730 hours = $98.55/month
  - Non-Production (1 NAT): $0.045 × 730 hours = $32.85/month
- **Data Processing**: $0.045 per GB processed
  - Production: ~10 GB/month = $0.45/month
  - Non-Production: ~5 GB/month = $0.23/month

#### VPC Endpoint Costs (Interface Endpoints)
- **Hourly Charge**: $0.01/hour per endpoint
  - 5 endpoints × $0.01 × 730 hours = $36.50/month
- **Data Processing**: $0.01 per GB (typically minimal, ~$0-5/month)
- **Total**: ~$36.50-41.50/month

#### VPC Flow Logs Costs
- **CloudWatch Logs Ingestion**: $0.50 per GB ingested
- **CloudWatch Logs Storage**: $0.03 per GB/month
- **Typical Production**: ~15-20 GB/month = $10-15/month
- **Typical Non-Production**: ~5-10 GB/month = $5-10/month

#### Route 53 Costs
- **Hosted Zone**: $0.50/month per hosted zone
- **DNS Queries**: $0.40 per million queries
  - Production: ~1M queries/month = $0.40/month
  - Non-Production: ~500K queries/month = $0.20/month

### Cost Optimization Strategies

1. **Non-Production Environments**:
   - Set `single_nat_gateway = true` to save ~$65/month
   - Disable unnecessary VPC endpoints (save ~$7/month per endpoint)
   - Disable VPC Flow Logs if not needed (save ~$5-10/month)
   - Use smaller CIDR blocks if you don't need full /16 subnets

2. **Production Environments**:
   - Use multiple NAT Gateways for high availability (required for production)
   - Enable all VPC endpoints for security and reduced data transfer costs
   - Use larger CIDR blocks (/14 or /12) for scalability
   - Monitor VPC Flow Logs to optimize network traffic

3. **Cost Scaling**:
   - **Minimal**: Single NAT, no endpoints, no flow logs = ~$33/month
   - **Basic**: Single NAT, flow logs = ~$40/month
   - **Standard**: Single NAT, all endpoints, flow logs = ~$75-80/month
   - **Production**: Multi-AZ NAT, all endpoints, flow logs = ~$145-150/month

### Additional Cost Considerations

- **Data Transfer**: Costs vary based on usage
  - Data transfer within same AZ: Free
  - Data transfer between AZs: $0.01/GB
  - Data transfer out to internet: $0.09/GB (first 10 TB)
- **VPC Endpoint Data Transfer**: Can reduce data transfer costs by keeping traffic within AWS network
- **Reserved Capacity**: Consider NAT Gateway Reserved Capacity for predictable workloads (up to 50% savings)

## Post-Deployment

### 1. Update EKS Cluster Configuration

If you have an EKS cluster, update the `endpoint_public_access_cidrs` to use the allowlist prefix list:

```hcl
module "eks" {
  # ... other configuration ...
  
  endpoint_public_access_cidrs = [
    module.vpc.allowlist_prefix_list_id_ipv4
  ]
}
```

### 2. Configure DNS (if using domain)

After deployment, add NS records in your parent domain DNS provider:

```bash
terraform output hosted_zone_name_servers_list
```

Add these NS records to your parent domain (e.g., in Cloudflare or Route 53).

### 3. Update Security Groups

The module creates security groups that can be used by other resources:

- `jump_security_group_id`: For bastion hosts
- `public_security_group_id`: For public-facing resources
- `private_security_group_id`: For private resources
- `database_security_group_id`: For database resources
- `vpc_endpoints_security_group_id`: For VPC endpoints

## Outputs

After deployment, you can use the outputs to reference resources in other modules:

```hcl
module "eks" {
  source = "path/to/eks-module"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}

module "rds" {
  source = "path/to/rds-module"
  
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.database_subnet_ids
  security_group_id = module.vpc.database_security_group_id
}
```

## Security Considerations

1. **Allowlist**: Always configure `allowlist_ipv4_blocks` with your actual IPs. Never use `0.0.0.0/0` in production.

2. **Security Groups**: The module creates security groups with appropriate rules. Review and adjust as needed.

3. **VPC Endpoints**: Enable VPC endpoints to keep traffic within AWS network (improves security and reduces data transfer costs).

4. **Flow Logs**: Enable VPC Flow Logs for network monitoring and security auditing.

