# NetBird Example

This example demonstrates how to deploy EC2 instances with NetBird VPN client installed and connected to your NetBird network.

## Features

- **NetBird Installation**: Automatic installation and configuration of NetBird VPN client
- **Zero-Trust Network**: Connect instances to your NetBird zero-trust network
- **Secure Access**: SSM Session Manager support (recommended)
- **Stable IP**: Optional Elastic IP for consistent public IP address
- **DNS Integration**: Optional Route53 DNS records

## Prerequisites

- VPC module must be deployed first
- VPC remote state must be accessible
- NetBird account and setup key from [NetBird Management Dashboard](https://app.netbird.io)
- SSH key pair configured (optional if using SSM Session Manager)

## Getting NetBird Setup Key

1. Sign up or log in to [NetBird Management Dashboard](https://app.netbird.io)
2. Navigate to **Setup Keys** section
3. Create a new setup key or use an existing one
4. Copy the setup key (it looks like: `nkey_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

## Usage

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values:
   - `vpc_remote_state_bucket`: S3 bucket name for VPC remote state
   - `vpc_remote_state_key`: Remote state key for VPC module
   - `netbird_setup_key`: Your NetBird setup key (required)
   - `netbird_management_url`: Optional, only if using self-hosted NetBird management server
   - `domain`: Base domain for DNS records (optional)

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

- `instance_type`: t3.micro (default, can be adjusted based on needs)
- `ebs_volume_size`: 8 GB (default, minimum practical size)
- `enable_monitoring`: false (basic monitoring is free)
- `enable_termination_protection`: false (can be enabled for production)

### NetBird Configuration

- `netbird_setup_key`: **Required** - Setup key from NetBird Management Dashboard
- `netbird_management_url`: Optional - Only if using self-hosted NetBird management server

### Security Configuration

- `enable_ssm_session_manager`: true (recommended for secure access)
- `enable_eip`: false (optional, enable if you need stable public IP)

### DNS Configuration

- `domain`: null (optional, set if you want DNS records)
- `dns_enabled`: false (optional, enable if you want DNS records)

## Access Instances

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

### Via NetBird Network

Once NetBird is connected, you can access instances via their NetBird IP addresses:

```bash
# Check NetBird status
netbird status

# List NetBird peers
netbird status --peers

# Access via NetBird IP
ssh ubuntu@<netbird-ip>
```

## Verifying NetBird Connection

After deployment, verify NetBird is connected:

```bash
# Via SSM
aws ssm start-session --target <instance-id>

# Check NetBird status
sudo netbird status

# View NetBird logs
sudo journalctl -u netbird -f
```

## Outputs

After deployment, you can use the outputs:

```hcl
# Instance information
output "instance_ids" {
  value = module.ec2.instance_ids
}

# NetBird status
output "netbird_enabled" {
  value = module.ec2.netbird_enabled
}

# SSM Session Manager commands
output "ssm_commands" {
  value = module.ec2.ssm_session_commands
}
```

## Cost Estimation

### Monthly Cost Breakdown

- **Instance (t3.micro)**: ~$7.50/month (on-demand)
- **EBS Storage (8 GB gp3)**: ~$0.64/month
- **CloudWatch Monitoring**: Free (basic monitoring)
- **Elastic IP**: Free (when attached to instance)
- **Data Transfer**: Variable
- **Total**: ~$8-9/month

### Cost Optimization

1. **Use AWS Free Tier**: New accounts get 750 hours/month free (first 12 months)
2. **Use Reserved Instances**: Save up to 72% with 1-year or 3-year Reserved Instances
3. **Use Spot Instances**: For non-production workloads, save up to 90%
4. **Right-Size Storage**: Start with 8 GB, expand only when needed

## Self-Hosted NetBird Management Server

If you're using a self-hosted NetBird management server:

```hcl
netbird_management_url = "https://netbird.example.com"
netbird_setup_key      = "your-setup-key"
```

## Troubleshooting

### NetBird not connecting

1. Verify setup key is correct:
   ```bash
   sudo netbird status
   ```

2. Check NetBird logs:
   ```bash
   sudo journalctl -u netbird -f
   ```

3. Verify management URL (if using self-hosted):
   ```bash
   sudo netbird management show
   ```

4. Test connectivity:
   ```bash
   sudo netbird up --setup-key <your-setup-key>
   ```

### SSM Session Manager not working

1. Ensure `iam_instance_profile_enabled = true` (if using SSM)
2. Verify SSM Agent is running:
   ```bash
   systemctl status amazon-ssm-agent
   ```
3. Check IAM role has `AmazonSSMManagedInstanceCore` policy

### Cannot access via NetBird network

1. Verify NetBird is connected:
   ```bash
   sudo netbird status
   ```

2. Check NetBird IP assignment:
   ```bash
   ip addr show netbird0
   ```

3. Verify firewall rules allow NetBird traffic:
   ```bash
   sudo ufw status
   ```

## Next Steps

1. **Verify Connection**: Check NetBird status on the instance
2. **Configure Peers**: Add other devices to your NetBird network
3. **Set Up Routes**: Configure routing rules in NetBird Management Dashboard
4. **Access Resources**: Use NetBird IPs to access instances securely

## NetBird Resources

- [NetBird Documentation](https://docs.netbird.io/)
- [NetBird Management Dashboard](https://app.netbird.io)
- [NetBird GitHub](https://github.com/netbirdio/netbird)

For more information, see the main [README](../../README.md).
