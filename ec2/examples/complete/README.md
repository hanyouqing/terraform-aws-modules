# Complete EC2 Example

This example demonstrates a production-ready EC2 instance configuration with all features enabled.

## Features

- Production-ready instance type (t3.medium)
- Detailed CloudWatch monitoring
- Larger EBS volume (60 GB)
- Termination protection enabled
- IAM instance profile with service access
- Route53 DNS records
- IPv6 support (optional)
- Application Load Balancer (ALB) support
- Classic Load Balancer (ELB) support
- Auto Scaling Group (ASG) support
- Spot instance support

## Prerequisites

- VPC module must be deployed first
- VPC remote state must be accessible
- SSH key pair configured (via `key_path` or `key_name`)
- Route53 hosted zone (if using DNS)

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
   - `domain`: Base domain for DNS records (optional)
   - Configure load balancer, auto scaling, and other features as needed

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

### Instance Configuration

- `instance_count`: Number of instances to create (default: 1)
- `instance_type`: EC2 instance type (default: t3.medium)
- `enable_monitoring`: Enable detailed CloudWatch monitoring (default: true)
- `ebs_volume_size`: EBS volume size in GB (default: 60)
- `ebs_volume_type`: EBS volume type (default: gp3)
- `ebs_encrypted`: Enable EBS encryption (default: true)
- `enable_termination_protection`: Enable termination protection (default: true)

### Load Balancer Configuration

- `enable_alb`: Enable Application Load Balancer (default: true)
- `alb_port`: ALB listener port (default: 80)
- `alb_target_port`: ALB target port (default: 80)
- `alb_protocol`: ALB listener protocol (default: HTTP)
- `alb_target_protocol`: ALB target protocol (default: HTTP)
- `enable_elb`: Enable Classic Load Balancer (default: false)
- `elb_listener_port`: ELB listener port (default: 80)
- `elb_instance_port`: ELB instance port (default: 80)
- `elb_listener_protocol`: ELB listener protocol (default: HTTP)

### Auto Scaling Group Configuration

- `enable_autoscaling`: Enable Auto Scaling Group (default: false)
- `asg_min_size`: Minimum number of instances (default: 1)
- `asg_max_size`: Maximum number of instances (default: 3)
- `asg_desired_capacity`: Desired number of instances (default: 1)

### Spot Instance Configuration

- `spot_instance_enabled`: Enable Spot instances (default: false)
- `spot_instance_type`: Instance type for Spot instances (optional)
- `spot_interruption_behavior`: Interruption behavior (default: terminate)
- `spot_price`: Maximum price per hour (optional)

### IAM Permissions

- `iam_instance_profile_enabled`: Enable IAM instance profile (default: true)
- `enable_rds`: Enable RDS access permissions (default: false)
- `enable_ecr`: Enable ECR access permissions (default: false)
- `enable_eks`: Enable EKS access permissions (default: false)
- `enable_elasticache`: Enable ElastiCache access permissions (default: false)

### DNS Configuration

- `domain`: Base domain for DNS records (optional)
- `dns_enabled`: Enable Route53 DNS records (default: true)
- `dns_ttl`: TTL for DNS records in seconds (default: 60)

### Network Configuration

- `enable_ipv6`: Enable IPv6 support (default: false)

## SSH Access

After deployment, SSH to the instance:

```bash
# Get instance information:
terraform output instance_public_ips

# SSH using the public IP:
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>

# Or using DNS name (if DNS enabled):
terraform output dns_names
ssh -i ~/.ssh/your-key.pem ubuntu@<dns-name>
```

## SSM Session Manager Access

If SSM Session Manager is enabled, connect without SSH keys:

```bash
# Get instance IDs:
terraform output instance_ids

# Connect via SSM:
aws ssm start-session --target <instance-id>

# Or use the output command:
terraform output -raw ssm_session_commands
```

## Cost Considerations

This complete example uses production-ready settings with all features enabled.

### Monthly Cost Breakdown

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| **EC2 Instance (t3.medium)** | 1 | $0.0416/hour | ~$30.37 |
| **EBS Storage (gp3, 60 GB)** | 60 GB | $0.08/GB-month | ~$4.80 |
| **EBS I/O Requests** | ~3M IOPS | $0.005/million IOPS | ~$0.02 |
| **CloudWatch Monitoring** | Detailed | $0.015/metric | ~$2.16 |
| **CloudWatch Logs** | ~5 GB | $0.50/GB ingested | ~$2.50 |
| **CloudWatch Logs Storage** | ~5 GB | $0.03/GB-month | ~$0.15 |
| **Route53 DNS Queries** | ~100K queries | $0.40/million | ~$0.04 |
| **Elastic IP** | 1 | Free (when attached) | $0 |
| **Data Transfer Out** | ~50 GB | $0.09/GB (first 10 TB) | ~$4.50 |
| **EC2 Key Pair** | 1 | Free | $0 |
| **Security Group** | Uses VPC SG | Free | $0 |
| **IAM Role/Profile** | 1 | Free | $0 |

**Total Estimated Monthly Cost**: ~$44.58/month

### Detailed Cost Breakdown

#### EC2 Instance Costs
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **On-Demand Pricing**: $0.0416/hour (us-east-1)
- **Monthly Cost**: $0.0416 × 730 hours = $30.368/month
- **Reserved Instance Savings**: Up to 72% with 1-year or 3-year Reserved Instances
  - 1-year RI: ~$8.50/month (savings: ~$21.87/month)
  - 3-year RI: ~$6.00/month (savings: ~$24.37/month)
- **Savings Plans**: Up to 72% savings with 1-year or 3-year commitments

#### EBS Storage Costs
- **Volume Type**: gp3 (General Purpose SSD)
- **Storage**: 60 GB × $0.08/GB-month = $4.80/month
- **IOPS**: Included 3,000 IOPS (free)
- **Throughput**: Included 125 MB/s (free)
- **Additional IOPS**: $0.005 per million IOPS (typically minimal)
- **Encryption**: Free (KMS encryption included)

#### CloudWatch Monitoring Costs
- **Detailed Monitoring**: $0.015 per metric (enabled)
  - Typical metrics: ~144 metrics (CPU, Network, Disk, etc.)
  - Cost: 144 metrics × $0.015 = $2.16/month
- **Basic Monitoring**: Free (5-minute intervals, not used in this example)

#### CloudWatch Logs Costs
- **Log Ingestion**: ~5 GB/month × $0.50/GB = $2.50/month
- **Log Storage**: ~5 GB × $0.03/GB-month = $0.15/month
- **Total**: ~$2.65/month

#### Route53 DNS Costs
- **DNS Queries**: ~100,000 queries/month × $0.40/million = $0.04/month
- **Hosted Zone**: Included in VPC module (if domain configured)

#### Data Transfer Costs
- **Data Transfer Out**: ~50 GB/month × $0.09/GB = $4.50/month
- **Data Transfer In**: Free
- **Data Transfer Between AZs**: Minimal (if any) = ~$0.50/month

### Cost Optimization Strategies

1. **Reserved Instances**: Use Reserved Instances or Savings Plans for predictable workloads
   - **1-year Reserved Instance**: ~$8.50/month (vs $30.37/month on-demand)
   - **3-year Reserved Instance**: ~$6.00/month (vs $30.37/month on-demand)
   - **Savings**: Up to $24.37/month (80% savings)

2. **Spot Instances**: Use Spot Instances for non-production environments
   - **Spot Price**: ~$3.04/month (vs $30.37/month on-demand)
   - **Savings**: ~$27.33/month (90% savings)
   - ⚠️ **Note**: Spot instances can be interrupted with 2-minute notice

3. **Right-Sizing**: Monitor CloudWatch metrics and adjust instance type accordingly
   - If CPU utilization < 20%: Consider t3.small (~$15/month)
   - If memory utilization < 50%: Consider smaller instance types
   - Use AWS Compute Optimizer for recommendations

4. **Storage Optimization**: 
   - Start with 60 GB, monitor usage with CloudWatch
   - Expand only when needed (gp3 volumes can be resized without downtime)
   - Consider gp2 if you need consistent baseline performance (slightly cheaper for small volumes)

5. **CloudWatch Optimization**:
   - Use basic monitoring for non-production (save ~$2.16/month)
   - Reduce log retention period if not needed
   - Use log filters to reduce ingestion volume

6. **Data Transfer Optimization**:
   - Use VPC endpoints to reduce data transfer costs
   - Cache content at edge locations (CloudFront)
   - Optimize application to reduce outbound data transfer

### Cost Scaling

- **Minimal**: t3.micro, 8 GB, basic monitoring = ~$9.66/month
- **Standard**: t3.small, 20 GB, basic monitoring = ~$15/month
- **Production (this example)**: t3.medium, 60 GB, detailed monitoring = ~$44.58/month
- **High Performance**: t3.large, 100 GB, detailed monitoring = ~$90/month

### Additional Cost Considerations

#### Load Balancer Costs (if enabled)
- **Application Load Balancer**: ~$16-20/month (HTTPS termination, health checks)
- **Classic Load Balancer**: ~$18-25/month (legacy, use ALB instead)
- **ACM Certificate**: Free (automatically configured from VPC)

#### Auto Scaling Group Costs
- **ASG**: Free (no additional cost)
- **Launch Template**: Free
- **Scaling Activities**: Free

#### Spot Instance Costs
- **Spot Instances**: Up to 90% savings vs on-demand
- **Example**: t3.medium Spot ~$3-4/month (vs $30.37/month on-demand)

#### IAM Service Access Costs
- **RDS Access**: Free (IAM permissions only)
- **ECR Access**: Free (IAM permissions only)
- **EKS Access**: Free (IAM permissions only)
- **ElastiCache Access**: Free (IAM permissions only)

### Cost Comparison

| Configuration | Instance Type | Storage | Monitoring | Monthly Cost |
|---------------|---------------|---------|------------|--------------|
| **Basic Example** | t3.micro | 8 GB | Basic (free) | ~$9.66 |
| **This Example** | t3.medium | 60 GB | Detailed | ~$44.58 |
| **With Reserved Instance** | t3.medium | 60 GB | Detailed | ~$22.21 |
| **With Spot Instance** | t3.medium | 60 GB | Detailed | ~$14.21 |

### Monthly Cost Summary

- **On-Demand**: ~$44.58/month
- **With 1-year RI**: ~$22.21/month (50% savings)
- **With 3-year RI**: ~$19.71/month (56% savings)
- **With Spot Instance**: ~$14.21/month (68% savings, non-production only)

## Outputs

After deployment, you can use the outputs to reference the EC2 instances in other modules:

```hcl
output "instance_ips" {
  value = module.ec2.instance_public_ips
}

output "instance_dns" {
  value = module.ec2.dns_names
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}
```

## Troubleshooting

### Cannot SSH to instance
- Verify the security group allows SSH from your IP (check VPC allowlist)
- Ensure the EC2 Key Pair is correctly configured
- Check CloudWatch logs for user data script execution
- Use SSM Session Manager if SSH is not available

### DNS records not created
- Verify Route53 hosted zone exists
- Check `domain` variable matches VPC module domain
- Verify `dns_enabled = true`
- If ALB is enabled, DNS will CNAME to ALB (not instance IP)

### Load Balancer health checks failing
- Verify security group allows traffic from ALB to instances
- Check target group health check configuration
- Review CloudWatch logs for application errors
- Verify target port matches application port

### Auto Scaling Group not scaling
- Check CloudWatch alarms and scaling policies
- Verify ASG min/max/desired capacity settings
- Review ASG activity history in AWS Console
