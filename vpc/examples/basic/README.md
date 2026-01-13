# Basic VPC Example

This example demonstrates a minimal VPC configuration suitable for testing environments.

## Features

- Single VPC with public and private subnets (minimal cost configuration)
- **NAT Gateway disabled by default** (saves ~$32/month)
- **VPC Flow Logs disabled by default** (saves ~$5-10/month)
- Multi-AZ deployment (2 availability zones for minimal resource count)
- Basic security groups
- **Estimated cost: ~$0/month** (only free AWS resources)

## Usage

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values

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

Update the following variables in `terraform.tfvars`:

- `region`: AWS region (default: us-east-1)
- `project`: Project name
- `environment`: Environment name (testing, staging, production)
- `vpc_cidr`: CIDR block for VPC (default: 10.0.0.0/16)
- `availability_zones`: List of availability zones
- `public_subnets`: CIDR blocks for public subnets
- `private_subnets`: CIDR blocks for private subnets
- `database_subnets`: CIDR blocks for database subnets

## Cost Considerations

This basic example is optimized for **minimal cost** - perfect for testing, development, or proof-of-concept environments.

### Monthly Cost Breakdown (Minimal Configuration)

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| **NAT Gateway** | 0 (disabled) | - | **$0** |
| **VPC Flow Logs** | 0 (disabled) | - | **$0** |
| **VPC** | 1 | Free | $0 |
| **Subnets** | 4 (2 public + 2 private, no database) | Free | $0 |
| **Route Tables** | 3 | Free | $0 |
| **Internet Gateway** | 1 | Free | $0 |
| **Security Groups** | 5 | Free | $0 |
| **Elastic IPs** | 0 | Free | $0 |
| **Managed Prefix List** | 0 (not configured) | Free | $0 |

**Total Estimated Monthly Cost**: **~$0/month** (only AWS free tier resources)

### Cost Details

- **NAT Gateway**: **Disabled by default** (saves ~$32.40/month)
  - ⚠️ **Note**: Private subnets won't have internet access without NAT Gateway
  - To enable: Set `enable_nat_gateway = true` in `terraform.tfvars`
- **VPC Flow Logs**: **Disabled by default** (saves ~$5-10/month)
  - To enable: Set `enable_flow_log = true` in `terraform.tfvars`
- **Database Subnets**: **Empty by default** (reduces resource count)
  - To enable: Add database subnets in `terraform.tfvars`
- **Availability Zones**: **Reduced to 2 AZs** (matches subnet count, reduces resource overhead)

### Cost Optimization Features

1. ✅ **NAT Gateway Disabled**: Saves ~$32.40/month
   - Public subnets still have internet access via Internet Gateway
   - Private subnets won't have outbound internet access
2. ✅ **VPC Flow Logs Disabled**: Saves ~$5-10/month
   - Enable only when you need network monitoring
3. ✅ **Minimal Subnets**: Only 2 public + 2 private subnets (no database subnets)
4. ✅ **2 Availability Zones**: Reduced from 3 to 2 AZs

### Enabling Optional Features (Additional Costs)

If you need additional features, you can enable them:

```hcl
# Enable NAT Gateway for private subnet internet access
enable_nat_gateway = true
single_nat_gateway = true  # Cost: ~$32.40/month

# Enable VPC Flow Logs for network monitoring
enable_flow_log = true  # Cost: ~$5-10/month

# Add database subnets
database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]  # Free (just subnets)
```

### Cost Comparison

| Configuration | Monthly Cost | Features |
|---------------|--------------|----------|
| **Minimal (default)** | **~$0** | VPC, subnets, IGW, security groups |
| **With NAT Gateway** | ~$32.40 | + Private subnet internet access |
| **With Flow Logs** | ~$5-10 | + Network monitoring |
| **With NAT + Flow Logs** | ~$37-43 | Both features enabled |
| **Complete Example** | ~$75-85 | All features (single NAT) |

### Use Cases for Minimal Configuration

- ✅ **Development/Testing**: Perfect for local development and testing
- ✅ **Proof of Concept**: Quick setup without ongoing costs
- ✅ **Learning**: Understanding VPC concepts without cost concerns
- ✅ **Public-only workloads**: Applications that only need public subnets

### Limitations

- ❌ **Private subnets**: No outbound internet access (no NAT Gateway)
- ❌ **Network monitoring**: No VPC Flow Logs
- ❌ **Database subnets**: Not configured by default

For production environments or workloads requiring private subnet internet access, enable NAT Gateway or use the `complete` example.

## Outputs

After deployment, you can use the outputs to reference the VPC and subnets in other modules:

```hcl
module "eks" {
  source = "path/to/eks-module"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

