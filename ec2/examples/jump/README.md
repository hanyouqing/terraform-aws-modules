# JumpServer Example

This example demonstrates how to deploy a JumpServer (跳板机) using the EC2 module.

## Features

- **JumpServer Installation**: Automatic deployment of JumpServer v2.28.8
- **Production-Ready**: t3.medium instance with 60GB storage
- **Secure Access**: SSM Session Manager support (recommended)
- **Stable IP**: Elastic IP for consistent public IP address
- **DNS Integration**: Route53 DNS records for easy access
- **IAM Integration**: Optional access to RDS, ECR, EKS, ElastiCache
- **Monitoring**: CloudWatch monitoring enabled

## Prerequisites

- VPC module must be deployed first
- VPC remote state must be accessible
- Route53 hosted zone (if using DNS)
- SSH key pair configured (optional if using SSM Session Manager)

## Usage

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values:
   - `vpc_remote_state_bucket`: S3 bucket name for VPC remote state
   - `vpc_remote_state_key`: Remote state key for VPC module
   - `domain`: Base domain for DNS records
   - `jump_db_password`: Database password (or leave null for auto-generation)

3. Configure backend in `backend.tf` (if using S3 backend)

4. Initialize Terraform:
```bash
terraform init
```

5. Review the plan:
```bash
terraform plan
```

6. Apply the configuration:
```bash
terraform apply
```

## Configuration

### Instance Configuration

- `instance_type`: t3.medium (recommended for JumpServer)
- `ebs_volume_size`: 60 GB (minimum for JumpServer)
- `enable_monitoring`: true (detailed CloudWatch monitoring)
- `enable_termination_protection`: true (protect from accidental deletion)

### JumpServer Configuration

- `jump_version`: JumpServer version (default: v2.28.8)
- `jump_db_host`: Database host (localhost for local MySQL, or RDS endpoint)
- `jump_db_password`: Database password (auto-generated if not provided)
- `jump_redis_host`: Redis host (localhost for local Redis, or ElastiCache endpoint)

### Security Configuration

- `enable_ssm_session_manager`: true (recommended for secure access)
- `enable_eip`: true (stable public IP address)
- `iam_instance_profile_enabled`: true (required for SSM and service access)

### DNS Configuration

- `domain`: Base domain for DNS records
- `dns_enabled`: true (enable Route53 DNS records)
- `dns_ttl`: 60 seconds (low TTL for faster updates)

## Access JumpServer

### Via SSM Session Manager (Recommended)

```bash
# Get instance ID
terraform output instance_ids

# Connect via SSM
aws ssm start-session --target <instance-id>

# Or use the output command
terraform output -raw ssm_session_commands
```

### Via SSH

```bash
# Get public IP
terraform output instance_public_ips

# Connect via SSH
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>
```

### Via Web UI

```bash
# Get JumpServer access URL
terraform output jump_access_url

# Open in browser
# Default credentials: admin/admin (change immediately!)
```

## Outputs

After deployment, you can use the outputs:

```hcl
# Instance information
output "jump_server_ip" {
  value = module.ec2.instance_public_ips
}

# JumpServer access URL
output "jump_server_url" {
  value = module.ec2.jump_access_url
}

# SSM Session Manager commands
output "ssm_commands" {
  value = module.ec2.ssm_session_commands
}
```

## Cost Estimation

### Monthly Cost Breakdown

- **Instance (t3.medium)**: ~$30/month (on-demand)
- **EBS Storage (60 GB gp3)**: ~$4.80/month
- **CloudWatch Monitoring**: ~$2.16/month (detailed monitoring)
- **Elastic IP**: Free (when attached to instance)
- **Data Transfer**: Variable
- **Total**: ~$37-40/month

### Cost Optimization

1. **Use Reserved Instances**: Save up to 72% with 1-year or 3-year Reserved Instances
2. **Use Spot Instances**: Not recommended for JumpServer (needs stable availability)
3. **Right-Size Storage**: Start with 60 GB, monitor usage and expand as needed

## External Database/Redis (Optional)

### Using RDS MySQL

```hcl
jump_db_host     = "jumpserver-db.xxxxx.ap-southeast-1.rds.amazonaws.com"
jump_db_port     = 3306
jump_db_user     = "jumpserver"
jump_db_password = "your-secure-password"
jump_db_name     = "jumpserver"
enable_rds       = true  # Enable RDS access permissions
```

### Using ElastiCache Redis

```hcl
jump_redis_host     = "jumpserver-redis.xxxxx.cache.amazonaws.com"
jump_redis_port     = 6379
jump_redis_password = "your-redis-password"
enable_elasticache  = true  # Enable ElastiCache access permissions
```

## Troubleshooting

### Cannot access JumpServer web UI

1. Verify security group allows HTTP (80) from your IP
2. Check JumpServer status:
   ```bash
   ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>
   cd /opt/jumpserver-installer-* && ./jmsctl.sh status
   ```
3. View logs:
   ```bash
   cd /opt/jumpserver-installer-* && ./jmsctl.sh logs
   ```

### Database connection failed

1. Verify `jump_db_password` is set correctly
2. Check database host is accessible from instance
3. For RDS: Verify security group allows connection from EC2 security group
4. Test connection:
   ```bash
   mysql -h <db_host> -P <db_port> -u <db_user> -p
   ```

### SSM Session Manager not working

1. Ensure `iam_instance_profile_enabled = true`
2. Verify SSM Agent is running:
   ```bash
   systemctl status amazon-ssm-agent
   ```
3. Check IAM role has `AmazonSSMManagedInstanceCore` policy

## Next Steps

1. **Change Default Password**: Access JumpServer web UI and change admin password immediately
2. **Configure Users**: Add users and configure permissions
3. **Add Assets**: Register servers and assets to manage
4. **Configure Access**: Set up access policies and permissions

For more information, see the main [README](../../README.md).
