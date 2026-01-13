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

This complete example includes all features:

### Monthly Cost Breakdown

- **NAT Gateways** (3 AZs): ~$96/month (3 × $32)
  - Use `single_nat_gateway = true` for non-production: ~$32/month
- **VPC Endpoints** (Interface): ~$7/month per endpoint × 5 = ~$35/month
  - ECR DKR, ECR API, EKS, CloudWatch Logs, Secrets Manager
- **VPC Endpoint** (Gateway - S3): Free
- **VPC Flow Logs**: ~$5-10/month (depending on traffic)
- **Route 53 Hosted Zone**: ~$0.50/month
- **ACM Certificate**: Free
- **Managed Prefix List**: Free

**Total Estimated Cost**:
- Production (multi-AZ): ~$140-150/month
- Non-production (single NAT): ~$75-85/month

### Cost Optimization Strategies

1. **Non-Production Environments**:
   - Set `single_nat_gateway = true` to save ~$64/month
   - Disable unnecessary VPC endpoints
   - Use smaller CIDR blocks

2. **Production Environments**:
   - Use multiple NAT Gateways for HA
   - Enable all VPC endpoints for security
   - Use larger CIDR blocks for scalability

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

