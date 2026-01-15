# GitLab Example

This example demonstrates how to deploy GitLab Community Edition (代码仓库) using the EC2 module.

## Features

- **GitLab Installation**: Automatic deployment of GitLab Community Edition
- **Production-Ready**: t3.medium instance with 30GB storage (cost-optimized)
- **Secure Access**: SSM Session Manager support (recommended)
- **Private Subnet**: GitLab deployed in private subnet for security
- **Load Balancer**: Application Load Balancer with HTTPS (enabled by default)
- **DNS Integration**: Route53 DNS records for easy access
- **IAM Integration**: Optional ECR access for container registry
- **Monitoring**: CloudWatch monitoring enabled

## Prerequisites

- VPC module must be deployed first
- VPC remote state must be accessible
- Route53 hosted zone (if using DNS)
- SSH key pair configured (optional if using SSM Session Manager)
- ACM certificate (if using HTTPS with ALB)

## Usage

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values:
   - `vpc_remote_state_bucket`: S3 bucket name for VPC remote state
   - `vpc_remote_state_key`: Remote state key for VPC module
   - `domain`: Base domain for DNS records
   - `gitlab_external_url`: External URL for GitLab (e.g., http://gitlab.example.com)

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

- `instance_type`: t3.medium (cost-optimized, 2 vCPU, 4GB RAM - suitable for small to medium teams)
- `ebs_volume_size`: 30 GB (cost-optimized, expand as needed)
- `enable_monitoring`: false (basic monitoring - free, enable detailed for production)
- `enable_termination_protection`: false (cost-optimized, enable for production)
- `subnet_type`: private (GitLab in private subnet for security)

### GitLab Configuration

- `gitlab_external_url`: External URL for GitLab (e.g., http://gitlab.example.com)
- `gitlab_http_port`: HTTP port (default: 80)
- `gitlab_https_port`: HTTPS port (default: 443)
- `gitlab_ssh_port`: SSH port for Git operations (default: 22)

### Security Configuration

- `enable_ssm_session_manager`: true (recommended for secure access)
- `enable_eip`: false (GitLab in private subnet, accessed via ALB - no public IP needed)
- `iam_instance_profile_enabled`: true (required for SSM and ECR access)
- `subnet_type`: private (GitLab deployed in private subnet for security)
- **Security Group**: Automatically uses `private_security_group_id` from VPC module when `subnet_type = "private"`

### Load Balancer Configuration

- `enable_alb`: true (enabled by default for HTTPS and security)
- `alb_port`: 443 (HTTPS port)
- `alb_protocol`: HTTPS (automatically configured when DNS and certificate available)
- `alb_certificate_arn`: null (auto-fetched from VPC if available)

### DNS Configuration

- `domain`: Base domain for DNS records
- `dns_enabled`: true (enable Route53 DNS records)
- `dns_ttl`: 60 seconds (low TTL for faster updates)

## Access GitLab

### Via SSM Session Manager (Recommended)

```bash
# Get instance ID
terraform output instance_ids

# Connect via SSM
aws ssm start-session --target <instance-id>

# Or use the output command
terraform output -raw ssm_session_commands
```

### Via SSH (through Jump Server)

```bash
# GitLab is in private subnet, access via jump server
# SSH config is automatically generated at ~/.ssh/conf.d/gitlab-production.conf
ssh gitlab-production

# Or get the SSH config file path
terraform output gitlab_ssh_config_file_path
```

### Via Web UI (HTTPS via ALB)

```bash
# Get GitLab HTTPS URL (via ALB with certificate)
terraform output gitlab_https_url

# Or HTTP URL (if ALB not enabled)
terraform output gitlab_access_url

# Open in browser
# Default root password: Check /etc/gitlab/initial_root_password on the server
# Note: GitLab is accessed via ALB (public) even though instance is in private subnet
```

## Initial Setup

After deployment, you need to:

1. **Get Root Password**:
   ```bash
   # Via SSM (recommended)
   aws ssm start-session --target <instance-id>
   sudo cat /etc/gitlab/initial_root_password
   
   # Or via SSH through jump server
   ssh gitlab-production
   sudo cat /etc/gitlab/initial_root_password
   ```

2. **Access GitLab Web UI**:
   - Open `http://<gitlab-url>` in browser
   - Login with username: `root` and password from step 1
   - Change password immediately

3. **Configure GitLab**:
   - Update external URL if needed
   - Configure SMTP for email notifications
   - Set up backup strategy
   - Configure container registry (if using)

## Outputs

After deployment, you can use the outputs:

```hcl
# Instance information (private IPs - GitLab in private subnet)
output "gitlab_server_ips" {
  value = module.ec2.instance_private_ips
}

# GitLab HTTPS access URL (via ALB)
output "gitlab_https_url" {
  value = module.ec2.gitlab_https_url
}

# GitLab HTTP access URL
output "gitlab_url" {
  value = module.ec2.gitlab_access_url
}

# ALB DNS name (HTTPS endpoint)
output "alb_dns" {
  value = module.ec2.alb_dns_name
}

# SSH config file path (for jump server access)
output "gitlab_ssh_config" {
  value = local_file.gitlab_ssh_config[0].filename
}

# SSM Session Manager commands
output "ssm_commands" {
  value = module.ec2.ssm_session_commands
}
```

## Cost Estimation

### Monthly Cost Breakdown

- **Instance (t3.medium)**: ~$30/month (on-demand, cost-optimized)
- **EBS Storage (30 GB gp3)**: ~$2.40/month (cost-optimized)
- **CloudWatch Monitoring**: Free (basic monitoring)
- **ALB** (enabled by default): ~$16-20/month (HTTPS with certificate)
- **Data Transfer**: Variable
- **Total**: ~$48-50/month (cost-optimized with ALB)

### Cost Optimization

1. **Use Reserved Instances**: Save up to 72% with 1-year or 3-year Reserved Instances
2. **Right-Size Storage**: Start with 100 GB, monitor usage and expand as needed
3. **Use ALB Only for Production**: Skip ALB for development/testing environments

## Production Recommendations

### High Availability Setup

1. **Multiple Instances**: Use `instance_count = 2` or more
2. **Application Load Balancer**: Enable ALB for load balancing
3. **External Database**: Use RDS PostgreSQL for GitLab database
4. **External Storage**: Use S3 for GitLab object storage
5. **Backup Strategy**: Configure automated backups to S3

### Security Hardening

1. **HTTPS**: Use ACM certificate with ALB for HTTPS
2. **SSM Session Manager**: Use instead of SSH for access
3. **Security Groups**: Restrict access to necessary IPs only
4. **Regular Updates**: Keep GitLab updated to latest version
5. **Backup Encryption**: Encrypt backups stored in S3

### Performance Optimization

1. **Instance Size**: Use t3.xlarge or larger for high-traffic scenarios
2. **Storage**: Use io1/io2 volumes for better IOPS if needed
3. **ALB**: Use ALB for better performance and SSL termination
4. **CDN**: Use CloudFront for static assets (if using S3)

## ECR Integration (Optional)

If you want to use GitLab Container Registry with AWS ECR:

```hcl
enable_ecr = true  # Enable ECR access permissions
```

Then configure GitLab to use ECR as the container registry backend.

## Troubleshooting

### Cannot access GitLab web UI

1. Verify ALB health checks are passing (GitLab in private subnet, accessed via ALB)
2. Check GitLab HTTPS URL:
   ```bash
   terraform output gitlab_https_url
   ```
3. Check GitLab status via SSM:
   ```bash
   aws ssm start-session --target <instance-id>
   sudo gitlab-ctl status
   ```
4. View logs:
   ```bash
   sudo gitlab-ctl tail
   ```

### GitLab not starting

1. Check system resources:
   ```bash
   free -h
   df -h
   ```
2. Review GitLab configuration:
   ```bash
   sudo gitlab-ctl reconfigure
   ```
3. Check logs:
   ```bash
   sudo gitlab-ctl tail
   ```

### SSM Session Manager not working

1. Ensure `iam_instance_profile_enabled = true`
2. Verify SSM Agent is running:
   ```bash
   systemctl status amazon-ssm-agent
   ```
3. Check IAM role has `AmazonSSMManagedInstanceCore` policy

### ALB health checks failing

1. Verify security group allows traffic from ALB
2. Check GitLab is listening on the correct port
3. Verify health check path and port configuration

## Next Steps

1. **Initial Configuration**: Access GitLab web UI and complete initial setup
2. **Create Users**: Add users and configure permissions
3. **Create Projects**: Set up repositories and projects
4. **Configure CI/CD**: Set up GitLab CI/CD pipelines
5. **Set Up Backups**: Configure automated backups
6. **Monitor Performance**: Use CloudWatch to monitor instance performance

For more information, see the main [README](../../README.md).
