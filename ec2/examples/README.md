# EC2 Module Examples

This directory contains example configurations for the EC2 module.

## Examples

- **[basic](./basic/)**: Minimal EC2 instance configuration for testing environments
- **[complete](./complete/)**: Production-ready EC2 instance configuration with all features including:
  - SSM Session Manager support
  - CloudWatch Logs and Metrics
  - JumpServer installation (optional)
  - IAM instance profile with service access
  - Route53 DNS records
  - IPv6 support
- **[jump](./jump/)**: JumpServer (跳板机) deployment example with:
  - Automatic JumpServer installation
  - SSM Session Manager for secure access
  - Elastic IP for stable public IP
  - DNS integration
  - Optional RDS/ElastiCache integration
- **[gitlab](./gitlab/)**: GitLab Community Edition (代码仓库) deployment example with:
  - Automatic GitLab installation
  - SSM Session Manager for secure access
  - Elastic IP for stable public IP
  - Optional Application Load Balancer
  - DNS integration
  - ECR integration support
- **[netbird](./netbird/)**: NetBird VPN client deployment example with:
  - Automatic NetBird installation and configuration
  - Zero-trust network connectivity
  - SSM Session Manager for secure access
  - Optional Elastic IP
  - Optional DNS integration

## Quick Start

1. Choose an example based on your needs:
   - Use `basic` for testing/development
   - Use `complete` for production with all features
   - Use `jump` for JumpServer (跳板机) deployment
   - Use `gitlab` for GitLab Community Edition (代码仓库) deployment

2. Navigate to the example directory:
```bash
cd examples/basic    # or complete, jump, gitlab
```

3. Copy and configure environment variables (recommended):
```bash
cp .env.sh.example .env.sh
# Edit .env.sh with your specific values
source .env.sh
```

4. Copy and edit the variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values (if not using .env.sh)
```

5. Configure backend (if using S3 backend):
```bash
# Edit backend.tf with your S3 bucket configuration
```

6. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- VPC module must be deployed first
- VPC remote state must be accessible
- SSH key pair configured (via `key_path` or `key_name`)

## Common Configuration

All examples require:

- `vpc_remote_state_bucket`: S3 bucket name for VPC remote state
- `vpc_remote_state_key`: Remote state key for VPC module (default: vpc/terraform.tfstate)
- `project`: Project name
- `environment`: Environment name (development, testing, staging, production)

## Differences Between Examples

### Basic Example
- Single instance (t3.micro)
- Basic monitoring (free)
- Minimal EBS volume (8 GB)
- No termination protection
- No JumpServer
- Estimated cost: ~$8-9/month

### Complete Example
- Production-ready instance (t3.medium)
- Detailed CloudWatch monitoring
- Larger EBS volume (60 GB)
- Termination protection enabled
- JumpServer installation (optional)
- SSM Session Manager support (optional)
- CloudWatch Logs and Metrics (optional)
- IAM instance profile with service access
- Route53 DNS records
- Estimated cost: ~$37-40/month (without optional features)

### Jump Example
- JumpServer (跳板机) deployment
- t3.medium instance with 60GB storage
- Automatic JumpServer installation
- SSM Session Manager enabled
- Elastic IP for stable public IP
- DNS integration
- Optional RDS/ElastiCache integration
- Estimated cost: ~$37-40/month

### GitLab Example
- GitLab Community Edition (代码仓库) deployment
- t3.large instance with 100GB storage
- Automatic GitLab installation
- SSM Session Manager enabled
- Elastic IP for stable public IP
- Optional Application Load Balancer
- DNS integration
- ECR integration support
- Estimated cost: ~$70-90/month (without ALB), ~$86-106/month (with ALB)

## New Features Available

### SSM Session Manager
Enable secure, SSH-free access to instances:
```hcl
enable_ssm_session_manager = true
iam_instance_profile_enabled = true  # Required
```

Connect using:
```bash
aws ssm start-session --target <instance-id>
```

### CloudWatch Logs
Enable centralized logging:
```hcl
cloudwatch_logs_enabled = true
cloudwatch_logs_retention_days = 30
iam_instance_profile_enabled = true  # Required
```

### CloudWatch Metrics
Enable custom metrics collection:
```hcl
cloudwatch_metrics_enabled = true
iam_instance_profile_enabled = true  # Required
```

### Spot Instances
Enable cost optimization for non-production workloads:
```hcl
spot_instance_enabled = true
spot_interruption_behavior = "stop"  # or "terminate", "hibernate"
```

### Auto Scaling Group
Enable automatic scaling:
```hcl
enable_autoscaling = true
asg_min_size = 2
asg_max_size = 10
asg_desired_capacity = 3
```

### Multi-OS Support
Use different operating systems:
```hcl
os_type = "amazon-linux"  # ubuntu, amazon-linux, rhel, debian
os_version = "2023"       # Version depends on os_type
```

## Next Steps

After deploying an example, you can:

1. SSH to the instance:
```bash
# If using auto-uploaded key from ~/.ssh/{name_prefix}-{environment}.pub:
ssh -i ~/.ssh/{name_prefix}-{environment} ubuntu@<public-ip>

# Or if using manually specified key:
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>
```

2. Use SSM Session Manager (if enabled):
```bash
aws ssm start-session --target <instance-id>
```

3. Check CloudWatch Logs (if enabled):
```bash
aws logs tail <log-group-name> --follow
```

4. View outputs:
```bash
terraform output
```

## Cost Optimization Tips

1. **Use Spot Instances**: For non-production workloads, save up to 90%
2. **Use AWS Free Tier**: New accounts get 750 hours/month free (first 12 months)
3. **Use Reserved Instances**: Commit to 1-year for 60% savings
4. **Right-size instances**: Monitor CloudWatch metrics and adjust accordingly
5. **Stop instances when not in use**: Save instance costs (only pay for storage)

## Troubleshooting

### Cannot connect via SSM Session Manager
- Ensure `iam_instance_profile_enabled = true`
- Verify SSM Agent is running: `systemctl status amazon-ssm-agent`
- Check IAM role has `AmazonSSMManagedInstanceCore` policy

### CloudWatch Logs not appearing
- Ensure `iam_instance_profile_enabled = true`
- Verify IAM role has CloudWatch Logs permissions
- Check log group exists: `aws logs describe-log-groups`

### Spot instance interrupted
- This is expected behavior for Spot instances
- Use `spot_interruption_behavior = "stop"` to preserve data
- Consider using Reserved Instances for production workloads

For more information, see the main [README](../README.md).
