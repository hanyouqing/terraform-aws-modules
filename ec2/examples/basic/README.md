# Basic EC2 Example

This example demonstrates a minimal EC2 instance configuration suitable for testing environments.

## Features

- Single EC2 instance (t3.micro - smallest available)
- Basic monitoring (free)
- Minimal EBS volume (8 GB - minimum practical size)
- No termination protection
- CloudWatch Logs disabled (saves ~$0.50/month)
- Uses VPC module's jump security group
- **Estimated cost: ~$8.35/month** (or ~$0.64/month with AWS Free Tier)

## Prerequisites

- VPC module must be deployed first
- VPC remote state must be accessible
- SSH key pair configured (via `key_path` or `key_name`)

## Usage

1. Copy and configure environment variables (recommended):
```bash
cp .env.sh.example .env.sh
# Edit .env.sh with your specific values
source .env.sh
```

2. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Edit `terraform.tfvars` with your specific values (if not using .env.sh):
   - `vpc_remote_state_bucket`: S3 bucket name for VPC remote state (must match VPC backend.tf)
   - `vpc_remote_state_key`: Remote state key for VPC module (must match VPC backend.tf)
     - Default matches VPC basic example: `hanyouqing/terraform-aws-modules:vpc/examples/basic/terraform.tfstate`
   - `project`: Project name
   - `environment`: Environment name

4. Configure backend in `backend.tf` (if using S3 backend)

5. Initialize Terraform:
```bash
terraform init
```

6. Review the plan:
```bash
terraform plan
```

7. Apply the configuration:
```bash
terraform apply
```

## Configuration

Update the following variables in `terraform.tfvars`:

- `region`: AWS region (default: us-east-1)
- `project`: Project name
- `environment`: Environment name (testing, staging, production)
- `vpc_remote_state_bucket`: S3 bucket name for VPC remote state (must match VPC backend.tf)
- `vpc_remote_state_key`: Remote state key for VPC module (must match VPC backend.tf)
  - Default: `hanyouqing/terraform-aws-modules:vpc/examples/basic/terraform.tfstate` (matches VPC basic example)

## SSH Access

After deployment, SSH to the instance:

```bash
# If using auto-uploaded key from ~/.ssh/{name_prefix}-{environment}.pub:
ssh -i ~/.ssh/{name_prefix}-{environment} ubuntu@<public-ip>

# Or if using manually specified key:
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>
```

Get the public IP from outputs:
```bash
terraform output jump_instance_public_ip
```

## Cost Considerations

This basic example is optimized for **minimal cost** - perfect for testing, development, or proof-of-concept environments.

### Monthly Cost Breakdown (Minimal Configuration)

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| **EC2 Instance (t3.micro)** | 1 | $0.0104/hour | ~$7.60 |
| **EBS Storage (gp3, 8 GB)** | 8 GB | $0.08/GB-month | ~$0.64 |
| **EBS I/O Requests** | ~3M IOPS | $0.005/million IOPS | ~$0.02 |
| **CloudWatch Monitoring** | Basic (free) | Free | $0 |
| **CloudWatch Logs** | Disabled | - | $0 |
| **Elastic IP** | 1 | Free (when attached) | $0 |
| **Data Transfer Out** | Minimal (~1 GB) | $0.09/GB | ~$0.09 |
| **EC2 Key Pair** | 1 | Free | $0 |
| **Security Group** | Uses VPC SG | Free | $0 |

**Total Estimated Monthly Cost**: **~$8.35/month**

### Detailed Cost Breakdown

#### EC2 Instance Costs
- **Instance Type**: t3.micro (2 vCPU, 1 GB RAM) - Smallest available instance type
- **On-Demand Pricing**: $0.0104/hour (us-east-1)
- **Monthly Cost**: $0.0104 × 730 hours = $7.592/month
- **AWS Free Tier**: New AWS accounts get 750 hours/month free for t2.micro/t3.micro (first 12 months)
  - **With Free Tier**: ~$0.64/month (only EBS storage)
- **Reserved Instance Savings**: Up to 72% with 1-year or 3-year Reserved Instances
  - 1-year RI: ~$2.13/month (savings: ~$5.46/month)
  - 3-year RI: ~$1.50/month (savings: ~$6.09/month)

#### EBS Storage Costs
- **Volume Type**: gp3 (General Purpose SSD) - Most cost-effective
- **Storage**: 8 GB × $0.08/GB-month = $0.64/month (minimum practical size)
- **IOPS**: Included 3,000 IOPS (free)
- **Throughput**: Included 125 MB/s (free)
- **Additional IOPS**: $0.005 per million IOPS (typically minimal)

#### CloudWatch Costs
- **Basic Monitoring**: Free (5-minute intervals)
- **Detailed Monitoring**: Not enabled (would cost ~$2.16/month if enabled)
- **CloudWatch Logs**: Disabled by default (saves ~$0.50/month)
  - To enable: Configure user_data or enable logging in your application

#### Data Transfer Costs
- **Data Transfer Out**: Minimal (~1 GB/month) × $0.09/GB = ~$0.09/month
- **Data Transfer In**: Free
- **Data Transfer Between AZs**: Free (within VPC)

### Cost Optimization Features

1. ✅ **t3.micro Instance**: Smallest available instance type (~$7.60/month)
2. ✅ **8 GB Storage**: Minimum practical EBS volume size (~$0.64/month)
3. ✅ **Basic Monitoring**: Free CloudWatch monitoring (no additional cost)
4. ✅ **No CloudWatch Logs**: Disabled by default (saves ~$0.50/month)
5. ✅ **Minimal Data Transfer**: Assumes minimal outbound traffic (~$0.09/month)

### Further Cost Optimization Options

#### 1. Use AWS Free Tier (New Accounts)
- **First 12 months**: 750 hours/month free for t2.micro/t3.micro
- **Cost with Free Tier**: ~$0.64/month (only EBS storage)
- **Savings**: ~$7.60/month

#### 2. Use Reserved Instances (1-year commitment)
- **1-year Reserved Instance**: ~$2.13/month (vs $7.60/month on-demand)
- **Total Cost**: ~$2.77/month (instance + storage)
- **Savings**: ~$5.83/month (60% savings)

#### 3. Use Spot Instances (Non-production only)
- **Spot Price**: ~$0.76/month (vs $7.60/month on-demand)
- **Total Cost**: ~$1.40/month (instance + storage)
- **Savings**: ~$6.95/month (83% savings)
- ⚠️ **Note**: Spot instances can be interrupted with 2-minute notice

#### 4. Stop Instance When Not in Use
- **Stopped Instance**: Only pay for EBS storage (~$0.64/month)
- **Savings**: ~$7.60/month when stopped
- **Use Case**: Development/testing environments that don't need 24/7 uptime

### Cost Comparison

| Configuration | Monthly Cost | Notes |
|---------------|--------------|-------|
| **Minimal (default)** | **~$8.35** | On-demand, basic monitoring |
| **With AWS Free Tier** | **~$0.64** | First 12 months only |
| **With Reserved Instance** | ~$2.77 | 1-year commitment |
| **With Spot Instance** | ~$1.40 | Can be interrupted |
| **Stopped Instance** | ~$0.64 | Only EBS storage |
| **Complete Example** | ~$44.58 | Production-ready |

### Cost Scaling

- **Minimal (this example)**: t3.micro, 8 GB, basic monitoring = ~$8.35/month
- **Standard**: t3.small, 20 GB, basic monitoring = ~$15/month
- **Production**: t3.medium, 60 GB, detailed monitoring = ~$44.58/month

### Use Cases for Minimal Configuration

- ✅ **Development/Testing**: Perfect for local development and testing
- ✅ **Proof of Concept**: Quick setup with minimal ongoing costs
- ✅ **Learning**: Understanding EC2 concepts without high costs
- ✅ **Low-traffic applications**: Applications with minimal resource requirements

### Tips to Minimize Costs

1. **Stop instances when not in use**: Save ~$7.60/month per stopped instance
2. **Use AWS Free Tier**: New accounts get 750 hours/month free (first 12 months)
3. **Use Reserved Instances**: Commit to 1-year for 60% savings
4. **Use Spot Instances**: For non-critical workloads (83% savings, but can be interrupted)
5. **Monitor usage**: Use CloudWatch to identify unused resources
6. **Right-size storage**: Start with 8 GB, expand only when needed

For production environments, consider using the `complete` example with better instance types and monitoring.

## Outputs

After deployment, you can use the outputs to reference the EC2 instance in other modules:

```hcl
output "instance_ip" {
  value = module.ec2.instance_public_ip
}
```
