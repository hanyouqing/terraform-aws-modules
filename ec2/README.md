# EC2 Instance Terraform Module

A production-ready Terraform module for creating AWS EC2 instances running Ubuntu 24.04 LTS (or other operating systems), configured with security best practices and automated system setup. It optionally includes automatic deployment of [JumpServer](https://jumpserver.com), an open-source Privileged Access Management (PAM) platform, or GitLab Community Edition.

## Features

- Ubuntu 24.04 LTS AMI (automatically fetched)
- **Optional IPv6 Support**: Enable IPv6 addressing for instances (default: disabled)
- Security group with SSH access from VPC allowlist (or anywhere if allowlist not configured)
- User data script for automated system initialization
- **Optional JumpServer Installation**: Automatic deployment of JumpServer v2.28.8 with Docker Compose
- **JumpServer Security**: Auto-generated SECRET_KEY and BOOTSTRAP_TOKEN (or use provided values)
- **JumpServer Ports**: HTTP (80), HTTPS (443), SSH (2222), RDP (3389) configured in security groups
- EBS encryption support
- CloudWatch monitoring
- Instance metadata service v2 (IMDSv2) enabled
- Termination protection (configurable)
- Integration with existing VPC infrastructure
- Native `aws_instance` resources (no nested community EC2 module)

## Features

- ✅ Multiple operating systems support (Ubuntu, Amazon Linux, RHEL, Debian)
- ✅ Multiple instance support (via `instance_count` or `instances` map)
- ✅ Security group integration with VPC module
- ✅ Optional IPv6 support
- ✅ User data scripts for automated system initialization
- ✅ Optional JumpServer installation
- ✅ Optional GitLab Community Edition installation
- ✅ IAM instance profile with service access (RDS, ECR, EKS, ElastiCache)
- ✅ Route53 DNS records (optional)
- ✅ EBS encryption support
- ✅ CloudWatch monitoring and logs (optional)
- ✅ Instance metadata service v2 (IMDSv2) enabled
- ✅ Termination protection (configurable)
- ✅ **SSM Session Manager support** - Secure, SSH-free access to instances
- ✅ **Spot instance support** - Cost optimization for non-production workloads
- ✅ **Auto Scaling Group support** - Automatic scaling based on demand
- ✅ **Application Load Balancer (ALB) support** - Modern load balancing
- ✅ **Classic Load Balancer (ELB) support** - Legacy load balancing
- ✅ **Elastic IP support** - Static public IP addresses

## Prerequisites

- **VPC module must be deployed first** - This module uses the VPC module's remote state to get network resources (subnets, security groups, allowlist)
- AWS credentials configured with appropriate permissions
- Terraform >= 1.14
- AWS Provider >= 6.28
- **EC2 Key Pair for SSH access**:
  - **Option 1 (Recommended)**: Place your SSH public key at `~/.ssh/{name_prefix}-{environment}.pub` (e.g., `~/.ssh/ec2-production.pub`) - it will be automatically uploaded to AWS
  - **Option 2**: Manually specify `key_name` variable with an existing EC2 Key Pair name
- **Route53 Hosted Zone**: VPC module domain will be used if available, otherwise uses `domain` variable (optional) for DNS records

## Architecture

EC2 instances are deployed in the VPC's public or private subnet with:
- **Network**: Uses VPC module's public subnet (automatically selected from VPC remote state)
- **Public IP address**: For direct SSH access
- **IPv6 Support**: Optional IPv6 addressing (requires subnet to have IPv6 CIDR block, default: disabled)
- **DNS Records**: Route53 A records automatically created (format: `{name_prefix}-{number}.{environment}.{domain}`, e.g., `ec2-1.production.example.com`)
- **Security Group**: 
  - SSH (22): From VPC allowlist or anywhere
  - HTTP (80): From VPC allowlist or anywhere (when JumpServer enabled)
  - HTTPS (443): From VPC allowlist or anywhere (when JumpServer enabled)
  - JumpServer SSH (2222): From VPC allowlist or anywhere (when JumpServer enabled)
  - JumpServer RDP (3389): From VPC allowlist or anywhere (when JumpServer enabled)
- **Egress**: All outbound traffic allowed
- **Storage**: 
  - Without JumpServer: EBS root volume (minimum 8 GB) with encryption enabled by default
  - With JumpServer: EBS root volume (minimum 60 GB) with encryption enabled by default
- **Instance Type**:
  - Without JumpServer: t3.micro (default)
  - With JumpServer: t3.large (default, 2 vCPU, 8GB RAM - meets JumpServer minimum requirements)
- **Cost Optimization**: Uses appropriate instance types based on JumpServer configuration, basic CloudWatch monitoring (free) by default

## Usage

### Basic Example

```hcl
module "ec2" {
  source = "path/to/ec2"

  project     = "my-project"
  environment = "testing"
  region      = "us-east-1"

  vpc_remote_state_bucket = "my-terraform-state-bucket"
  vpc_remote_state_key    = "vpc/terraform.tfstate"

  instance_count = 1

  instance_defaults = {
    instance_type                 = "t3.micro"
    enable_monitoring             = false
    ebs_volume_size               = 8
    enable_termination_protection = false
  }

  tags = {
    Owner      = "Team"
    CostCenter = "Infrastructure"
  }
}
```

### Example with SSM Session Manager

```hcl
module "ec2" {
  source = "path/to/ec2"

  project     = "my-project"
  environment = "production"
  region      = "us-east-1"

  vpc_remote_state_bucket = "my-terraform-state-bucket"
  vpc_remote_state_key    = "vpc/terraform.tfstate"

  instance_count = 1

  # Enable SSM Session Manager for secure access
  enable_ssm_session_manager = true
  iam_instance_profile_enabled = true  # Required for SSM

  instance_defaults = {
    instance_type = "t3.micro"
  }

  tags = {
    Owner = "Team"
  }
}
```

**Access via SSM Session Manager:**
```bash
# Connect to instance using SSM Session Manager
aws ssm start-session --target <instance-id>

# Or use the output command
terraform output -raw ssm_session_commands
```

### Example with Spot Instances

```hcl
module "ec2" {
  source = "path/to/ec2"

  project     = "my-project"
  environment = "development"
  region      = "us-east-1"

  vpc_remote_state_bucket = "my-terraform-state-bucket"
  vpc_remote_state_key    = "vpc/terraform.tfstate"

  instance_count = 2

  # Enable Spot instances for cost savings
  spot_instance_enabled = true
  spot_interruption_behavior = "stop"  # or "terminate", "hibernate"

  instance_defaults = {
    instance_type = "t3.medium"
  }

  tags = {
    Owner = "Team"
  }
}
```

### Example with Auto Scaling Group

```hcl
module "ec2" {
  source = "path/to/ec2"

  project     = "my-project"
  environment = "production"
  region      = "us-east-1"

  vpc_remote_state_bucket = "my-terraform-state-bucket"
  vpc_remote_state_key    = "vpc/terraform.tfstate"

  # Enable Auto Scaling Group
  enable_autoscaling = true
  asg_min_size       = 2
  asg_max_size       = 10
  asg_desired_capacity = 3

  # Enable ALB for load balancing
  enable_alb = true
  alb_port   = 80

  instance_defaults = {
    instance_type = "t3.medium"
  }

  tags = {
    Owner = "Team"
  }
}
```

### Complete Example with JumpServer

```hcl
module "ec2" {
  source = "path/to/ec2"

  project     = "my-project"
  environment = "production"
  region      = "us-east-1"

  vpc_remote_state_bucket = "my-terraform-state-bucket"
  vpc_remote_state_key    = "vpc/terraform.tfstate"

  instance_count = 1

  instance_defaults = {
    instance_type                 = "t3.medium"
    enable_monitoring             = true
    ebs_volume_size               = 60
    enable_termination_protection = true
  }

  # JumpServer configuration
  jumpserver_enabled = true
  jumpserver_version = "v2.28.8"

  # IAM permissions
  iam_instance_profile_enabled = true
  enable_rds                    = true
  enable_ecr                    = true
  enable_eks                    = true
  
  # Attach external IAM policies
  ec2_external_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::123456789012:policy/MyCustomPolicy"
  ]

  # DNS configuration
  domain     = "example.com"
  dns_enabled = true

  tags = {
    Owner      = "Team"
    CostCenter = "Infrastructure"
  }
}
```

## Examples

See the [examples](./examples/) directory for ready-to-use configurations:

- **[basic](./examples/basic/)**: Minimal EC2 instance configuration for testing (~$8-9/month)
- **[complete](./examples/complete/)**: Production-ready configuration with all features
- **[jump](./examples/jump/)**: Cost-optimized JumpServer configuration with ALB (~$32-37/month)
- **[gitlab](./examples/gitlab/)**: Cost-optimized GitLab configuration with ALB (~$48-52/month)

**Note**: The `jump` and `gitlab` examples are configured for cost optimization with security:
- Use smaller instance types (t3.small for JumpServer, t3.medium for GitLab)
- Use minimal EBS volumes (20GB for JumpServer, 30GB for GitLab)
- Use basic CloudWatch monitoring (free)
- **ALB enabled by default** for HTTPS and security (~$16-20/month)
  - Automatic HTTPS with ACM certificate from VPC
  - HTTP to HTTPS redirect
  - Improved security and compliance
- Disable termination protection by default (can be enabled for production)
- For production, consider upgrading instance types and enabling additional features

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14 |
| aws | ~> 6.28 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.28 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | `""` | no |
| environment | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| region | AWS region | `string` | `"us-east-1"` | no |
| vpc_remote_state_bucket | S3 bucket name for VPC remote state | `string` | n/a | yes |
| vpc_remote_state_key | Remote state key for VPC module | `string` | `"vpc/terraform.tfstate"` | no |
| instance_count | Number of EC2 instances to create | `number` | `0` | no |
| instance_type | EC2 instance type | `string` | `null` | no |
| enable_monitoring | Enable detailed CloudWatch monitoring | `bool` | `false` | no |
| ebs_volume_size | Size of the EBS root volume in GB | `number` | `null` | no |
| enable_ssm_session_manager | Enable SSM Session Manager | `bool` | `false` | no |
| spot_instance_enabled | Enable Spot instances | `bool` | `false` | no |
| enable_autoscaling | Enable Auto Scaling Group | `bool` | `false` | no |
| cloudwatch_logs_enabled | Enable CloudWatch Logs | `bool` | `false` | no |
| cloudwatch_metrics_enabled | Enable CloudWatch metrics | `bool` | `false` | no |
| os_type | Operating system type (ubuntu, amazon-linux, rhel, debian) | `string` | `"ubuntu"` | no |
| os_version | Operating system version | `string` | `"24.04"` | no |
| jumpserver_enabled | Enable JumpServer installation | `bool` | `true` | no |
| domain | Base domain for DNS records | `string` | `null` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

See [variables.tf](./variables.tf) for the complete list of available variables.

### Optional Variables

- `project` - Project name (default: "devops", can be overridden in terraform.tfvars)
- `region` - AWS region (default: "ap-southeast-1")
- `instance_type` - EC2 instance type (default: "t3.micro" without JumpServer, "t3.medium" with JumpServer)
- `key_name` - EC2 Key Pair name for SSH access (optional: if `~/.ssh/{name_prefix}-{environment}.pub` exists, it will be automatically uploaded and used as default)
- `subnet_id` - Specific subnet ID (default: first public subnet from VPC)
- `hostname` - Hostname for the EC2 instance
- `enable_monitoring` - Enable detailed CloudWatch monitoring (default: false)
- `ebs_volume_size` - EBS root volume size in GB (default: 8 without JumpServer, 60 with JumpServer)
- `ebs_volume_type` - EBS volume type (default: "gp3")
- `ebs_encrypted` - Enable EBS encryption (default: true)
- `ebs_kms_key_id` - KMS key ID for EBS encryption (optional)
- `enable_termination_protection` - Enable termination protection (default: false)
- `userdata_script_path` - Path to userdata script (default: "scripts/userdata.ubuntu-24.04.minimal.sh", auto-switched to JumpServer script when enabled)
- `instance_count` - Number of instances to create (default: 0, uses legacy single instance)
- `instance_defaults` - Default configuration for instances when using instance_count
- `instance_overrides` - Map of instance-specific overrides

### JumpServer Variables

- `jumpserver_enabled` - Enable JumpServer installation (default: true)
- `jumpserver_version` - JumpServer version (default: "v2.28.8")
- `eks_cluster_arn` - EKS cluster ARN for IAM policy (optional, allows access to specific cluster)
- `iam_instance_profile_enabled` - Enable IAM instance profile for EKS/RDS/ElastiCache access (default: true)
- `iam_role_policy_arns` - List of IAM policy ARNs to attach to the IAM role (default: [])
- `ec2_external_policy_arns` - List of external IAM policy ARNs to attach to the IAM role. This is an alias for iam_role_policy_arns for clarity when attaching external policies (default: [])
- `iam_role_policies` - Map of additional IAM policies (JSON) to attach to the IAM role. Format: { policy_name => policy_json } (default: {})
- `enable_rds` - Enable RDS access permissions (Secrets Manager and RDS describe). When enabled, allows jump server to access RDS secrets and describe RDS instances (default: false)
- `enable_ecr` - Enable ECR access permissions. When enabled, allows jump server to pull/push Docker images from/to ECR repositories (default: false)
- `enable_eks` - Enable EKS access permissions. When enabled, allows jump server to describe EKS clusters and configure kubectl access (default: false)
- `enable_elasticache` - Enable ElastiCache access permissions. When enabled, allows jump server to describe ElastiCache clusters and nodes (default: false)
- `jumpserver_secret_key` - SECRET_KEY (50+ chars, auto-generated if not provided)
- `jumpserver_bootstrap_token` - BOOTSTRAP_TOKEN (24+ chars, auto-generated if not provided)
- `jumpserver_db_host` - Database host (default: "localhost", use RDS endpoint for external database)
- `jumpserver_db_port` - Database port (default: 3306)
- `jumpserver_db_user` - Database user (default: "root")
- `jumpserver_db_password` - Database password (required if JumpServer enabled)
- `jumpserver_db_name` - Database name (default: "jumpserver")
- `jumpserver_redis_host` - Redis host (default: "localhost", use ElastiCache endpoint for external Redis)
- `jumpserver_redis_port` - Redis port (default: 6379)
- `jumpserver_redis_password` - Redis password (optional)
- `jumpserver_http_port` - HTTP port (default: 80)
- `jumpserver_ssh_port` - SSH port (default: 2222)
- `jumpserver_rdp_port` - RDP port (default: 3389)
- `jumpserver_docker_subnet` - Docker subnet CIDR (default: "192.168.250.0/24")
- `jumpserver_log_level` - Log level: ERROR, WARNING, INFO, DEBUG (default: "ERROR")
- `enable_ipv6` - Enable IPv6 support for jump server instances (default: false, requires subnet to have IPv6 CIDR block)
- `domain` - Base domain for DNS records (default: "example.com", can be overridden in terraform.tfvars). If VPC remote state has a domain configured, it will be used; otherwise this default will be used.
- `dns_enabled` - Enable Route53 DNS records for jump server instances (default: true)
- `dns_ttl` - TTL for Route53 DNS records in seconds (default: 300)

## Outputs

| Name | Description |
|------|-------------|
| ec2_name | Name of the EC2 module |
| jump_instance_id | ID of the first jump server instance |
| jump_instance_arn | ARN of the first jump server instance |
| jump_instance_public_ip | Public IP address of the first jump server |
| jump_instance_private_ip | Private IP address of the first jump server |
| jump_instances | Map of all jump server instances with full details |
| jump_instance_ids | Map of instance IDs by instance name |
| jump_instance_public_ips | Map of public IP addresses by instance name |
| jump_instance_private_ips | Map of private IP addresses by instance name |
| jump_security_group_id | Security group ID |
| jump_security_group_arn | Security group ARN |
| jump_dns_names | Map of DNS names for jump server instances |
| jumpserver_enabled | Whether JumpServer is enabled |
| jumpserver_access_url | JumpServer web access URL map |
| jump_iam_role_arn | ARN of the IAM role attached to jump server instances |

See [outputs.tf](./outputs.tf) for the complete list of available outputs.

## Architecture

The module creates EC2 instances in the VPC's public subnet with:

```
EC2 Jump Server
├── Instance(s)
│   ├── Ubuntu 24.04 LTS AMI
│   ├── Instance Type (configurable)
│   ├── EBS Root Volume (encrypted)
│   ├── Public IP Address
│   ├── IPv6 Support (optional)
│   └── User Data Script
├── Security Group (from VPC module)
│   ├── SSH (22): From VPC allowlist
│   ├── HTTP (80): From VPC allowlist (if JumpServer enabled)
│   ├── HTTPS (443): From VPC allowlist (if JumpServer enabled)
│   └── JumpServer Ports (2222, 3389): From VPC allowlist (if JumpServer enabled)
├── IAM Instance Profile (optional)
│   ├── RDS Access (optional)
│   ├── ECR Access (optional)
│   ├── EKS Access (optional)
│   └── ElastiCache Access (optional)
├── Route53 DNS Records (optional)
│   └── Format: jump-{number}.{environment}.{domain}
└── EC2 Key Pair
    └── Auto-uploaded from ~/.ssh/jump-{environment}.pub (if exists)
```

## Security Considerations

1. **SSH Access**: The security group allows SSH from the VPC allowlist Managed Prefix List. If no allowlist is configured, it allows SSH from anywhere (0.0.0.0/0). Consider configuring the VPC allowlist for better security.

2. **Key Pair**: 
   - If `~/.ssh/{name_prefix}-{environment}.pub` exists, it will be automatically uploaded to AWS as EC2 Key Pair
   - Key Pair name format: `<project>-<name_prefix>-<environment>` (default: `<project>-ec2-<environment>`)
   - Always use an EC2 Key Pair for SSH access. Never store private keys in version control.
   - To use a different key, set `key_name` variable or place your key at `~/.ssh/{name_prefix}-{environment}.pub`

3. **Instance Metadata**: IMDSv2 is enabled by default, requiring session tokens for metadata access.

4. **EBS Encryption**: Encryption is enabled by default for the root volume.

5. **Monitoring**: Basic CloudWatch monitoring is enabled by default (free). Detailed monitoring can be enabled but costs extra.

## Cost Considerations

### Monthly Cost Breakdown

#### Basic Configuration (Without JumpServer)
- **Instance (t3.micro)**: ~$7.50/month (on-demand)
- **EBS Storage (8 GB gp3)**: ~$0.64/month
- **CloudWatch Monitoring**: Free (basic monitoring)
- **Data Transfer**: Variable
- **Total**: ~$8-9/month

#### JumpServer Configuration (Cost-Optimized with ALB)
- **Instance (t3.small)**: ~$15/month (on-demand)
- **EBS Storage (20 GB gp3)**: ~$1.60/month
- **Application Load Balancer**: ~$16-20/month (HTTPS termination, security)
- **Elastic IP**: ~$0/month (free when attached to running instance)
- **CloudWatch Monitoring**: Free (basic monitoring)
- **ACM Certificate**: Free (auto-configured from VPC)
- **Data Transfer**: Variable
- **Total**: ~$32-37/month

#### JumpServer Configuration (Without ALB - Cost-Optimized)
- **Instance (t3.small)**: ~$15/month (on-demand)
- **EBS Storage (20 GB gp3)**: ~$1.60/month
- **Elastic IP**: ~$0/month (free when attached to running instance)
- **CloudWatch Monitoring**: Free (basic monitoring)
- **Data Transfer**: Variable
- **Total**: ~$16-17/month (HTTP only, less secure)

#### JumpServer Configuration (Production)
- **Instance (t3.medium)**: ~$30/month (on-demand)
- **EBS Storage (60 GB gp3)**: ~$4.80/month
- **Application Load Balancer**: ~$16-20/month (HTTPS termination, security)
- **CloudWatch Monitoring**: ~$2.16/month (detailed monitoring)
- **ACM Certificate**: Free (auto-configured from VPC)
- **Data Transfer**: Variable
- **Total**: ~$53-57/month

#### GitLab Configuration (Cost-Optimized with ALB)
- **Instance (t3.medium)**: ~$30/month (on-demand)
- **EBS Storage (30 GB gp3)**: ~$2.40/month
- **Application Load Balancer**: ~$16-20/month (HTTPS termination, security)
- **Elastic IP**: ~$0/month (free when attached to running instance)
- **CloudWatch Monitoring**: Free (basic monitoring)
- **ACM Certificate**: Free (auto-configured from VPC)
- **Data Transfer**: Variable
- **Total**: ~$48-52/month

#### GitLab Configuration (Without ALB - Cost-Optimized)
- **Instance (t3.medium)**: ~$30/month (on-demand)
- **EBS Storage (30 GB gp3)**: ~$2.40/month
- **Elastic IP**: ~$0/month (free when attached to running instance)
- **CloudWatch Monitoring**: Free (basic monitoring)
- **Data Transfer**: Variable
- **Total**: ~$32-33/month (HTTP only, less secure)

#### GitLab Configuration (Production)
- **Instance (t3.large)**: ~$60/month (on-demand)
- **EBS Storage (100 GB gp3)**: ~$8/month
- **Application Load Balancer**: ~$16-20/month (HTTPS termination, security)
- **CloudWatch Monitoring**: ~$2.16/month (detailed monitoring)
- **ACM Certificate**: Free (auto-configured from VPC)
- **Data Transfer**: Variable
- **Total**: ~$86-90/month

**Additional Costs (Optional for Production)**
- **RDS MySQL**: ~$15-50/month (db.t3.micro to db.t3.small, depending on Multi-AZ)
- **ElastiCache Redis**: ~$13-30/month (cache.t3.micro to cache.t3.small)
- **CloudFront**: ~$0.085/GB (for CDN, first 10TB free per month)

**Note**: ALB is enabled by default in jump and gitlab examples for HTTPS and security.
- **ALB Cost**: ~$16-20/month (HTTPS termination, health checks, automatic HTTP to HTTPS redirect)
- **ACM Certificate**: Free (automatically configured from VPC module)
- **Benefits**: Improved security, SSL/TLS encryption, automatic certificate management

### Cost Optimization Strategies

1. **Cost-Optimized Configuration (Examples with ALB)**:
   - **JumpServer**: Use `t3.small` instance type (~$15/month vs ~$30/month for t3.medium)
   - **GitLab**: Use `t3.medium` instance type (~$30/month vs ~$60/month for t3.large)
   - Use basic CloudWatch monitoring (free) instead of detailed monitoring (~$2.16/month savings)
   - Use minimal EBS volumes (20GB for JumpServer, 30GB for GitLab)
   - Disable termination protection (optional, for cost optimization)
   - **ALB enabled by default** (~$16-20/month) for HTTPS and security
     - Automatic HTTPS with ACM certificate from VPC
     - HTTP to HTTPS redirect
     - Improved security and compliance
     - Can be disabled if cost is critical and HTTP is acceptable

2. **Non-Production Environments**:
   - Use `t3.micro` instance type (~$7.50/month)
   - Use basic CloudWatch monitoring (free)
   - Use minimal EBS volume (8-20 GB)
   - Disable termination protection
   - Consider Spot Instances (up to 90% savings)

3. **Production Environments**:
   - Use appropriate instance types (t3.small for JumpServer, t3.medium for GitLab minimum)
   - Enable detailed CloudWatch monitoring only when needed
   - Use larger EBS volumes as required (monitor usage first)
   - Enable termination protection for critical instances
   - Consider Reserved Instances or Savings Plans (up to 72% savings)

4. **Cost Scaling**:
   - **Cost-Optimized (with ALB)**: Single instance, local DB/Redis, basic monitoring, ALB
     - JumpServer: ~$32-37/month (with ALB for HTTPS)
     - GitLab: ~$48-52/month (with ALB for HTTPS)
   - **Cost-Optimized (without ALB)**: Single instance, local DB/Redis, basic monitoring
     - JumpServer: ~$16-17/month (HTTP only, less secure)
     - GitLab: ~$32-33/month (HTTP only, less secure)
   - **Small**: Single instance, local DB/Redis, basic monitoring, ALB (~$50/month)
   - **Medium**: Single instance, RDS db.t3.micro, ElastiCache cache.t3.micro, ALB (~$75/month)
   - **Large**: Single instance, RDS db.t3.small Multi-AZ, ElastiCache cache.t3.small, ALB (~$115/month)
   - **Enterprise**: Multiple instances, RDS Multi-AZ, ElastiCache cluster, ALB, CloudFront (~$200+/month)

### Cost Reduction Strategies

1. **Instance Type Optimization**:
   - **JumpServer**: Use `t3.small` instead of `t3.medium` (50% cost reduction, ~$15/month savings)
   - **GitLab**: Use `t3.medium` instead of `t3.large` (50% cost reduction, ~$30/month savings)
   - Monitor CPU/memory usage and right-size based on actual needs
   - Use `t3.micro` for development/testing environments

2. **Storage Optimization**:
   - Start with minimal EBS volumes (20GB for JumpServer, 30GB for GitLab)
   - Monitor usage and expand only when needed
   - Use gp3 instead of gp2 (20% cheaper, better performance)
   - Delete unused snapshots regularly

3. **Monitoring Optimization**:
   - Use basic CloudWatch monitoring (free) instead of detailed monitoring (~$2.16/month savings per instance)
   - Enable detailed monitoring only when troubleshooting or for production critical workloads
   - Set up CloudWatch Logs retention policies to avoid excessive log storage costs

4. **Reserved Instances & Savings Plans**:
   - Use Reserved Instances or Savings Plans for predictable workloads (up to 72% savings)
   - 1-year Reserved Instance: ~40% savings
   - 3-year Reserved Instance: ~72% savings

5. **Spot Instances**:
   - Use Spot Instances for non-production environments (up to 90% savings)
   - Suitable for development, testing, and fault-tolerant workloads
   - Not recommended for production JumpServer/GitLab (interruption risk)

6. **Load Balancer Optimization**:
   - **ALB enabled by default** in jump and gitlab examples for HTTPS and security
   - Cost: ~$16-20/month (HTTPS termination, health checks, automatic redirects)
   - Benefits: SSL/TLS encryption, automatic ACM certificate management, improved security
   - Can be disabled if cost is critical and HTTP is acceptable (saves ~$16-20/month)
   - Certificate: Automatically fetched from VPC module (free ACM certificate)
   - Use ALB for production deployments requiring HTTPS and security compliance

7. **Additional Optimizations**:
   - Use local MySQL/Redis instead of RDS/ElastiCache for cost-optimized deployments
   - Disable termination protection for non-production (optional)
   - Use Elastic IP only when needed (free when attached to running instance)
   - Monitor and optimize data transfer costs

## User Data Scripts

### Without JumpServer

The module uses `scripts/userdata.ubuntu-24.04.minimal.sh` which performs:
- System package updates
- Installation of common utilities (curl, wget, git, jq, etc.)
- Configuration of automatic security updates
- Firewall (UFW) configuration
- Fail2ban setup
- System limits and sysctl optimizations
- AWS CLI v2 installation
- Log rotation configuration

### With JumpServer

When `jumpserver_enabled = true`, the module uses `files/jumpserver.ubuntu-24.04.sh` (located in `terraform/jump/files/`) which performs:
- All base system setup (from minimal script)
- Docker and Docker Compose installation
- MySQL client and Redis tools installation
- JumpServer installer download and extraction
- JumpServer configuration with environment variables
- Database and Redis connectivity checks
- JumpServer installation and startup
- Auto-generation of SECRET_KEY and BOOTSTRAP_TOKEN (if not provided)

**JumpServer Installation Location**: `/opt/jumpserver-installer-<version>/`
**JumpServer Management**: Use `./jmsctl.sh` commands in the installation directory

## Module Information

This module uses the [terraform-aws-modules/ec2-instance/aws](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance) module version ~> 6.1, which is a community-maintained module following AWS best practices.

## Troubleshooting

### Cannot SSH to instance
- Verify the security group allows SSH from your IP (check VPC allowlist)
- Ensure the EC2 Key Pair is correctly configured
- Check CloudWatch logs for user data script execution

### User data script not running
- Check `/var/log/cloud-init-output.log` on the instance
- Verify the userdata script path is correct
- Check instance metadata service is accessible

### Instance not getting public IP
- Verify the subnet is a public subnet (has route to Internet Gateway)
- Check `associate_public_ip_address` is set to `true` (default)

### JumpServer Issues

#### JumpServer not starting
- Check installation logs: `/var/log/jumpserver-install.log`
- Verify database connectivity: `mysql -h <db_host> -u <db_user> -p`
- Verify Redis connectivity: `redis-cli -h <redis_host> -p <redis_port> ping`
- Check Docker status: `systemctl status docker`
- View JumpServer logs: `cd /opt/jumpserver-installer-* && ./jmsctl.sh logs`

#### Cannot access JumpServer web UI
- Verify security group allows HTTP (80) from your IP
- Check JumpServer status: `cd /opt/jumpserver-installer-* && ./jmsctl.sh status`
- Verify HTTP port configuration: Check `JUMPSERVER_HTTP_PORT` in config
- Check instance public IP: Use `terraform output jumpserver_access_url`

#### Database connection failed
- Verify `jumpserver_db_password` is set correctly
- Check database host is accessible from instance
- For RDS: Verify security group allows connection from jump server security group
- Test connection: `mysql -h <db_host> -P <db_port> -u <db_user> -p<password>`

#### Redis connection failed
- Verify Redis host is accessible from instance
- For ElastiCache: Verify security group allows connection from jump server security group
- Test connection: `redis-cli -h <redis_host> -p <redis_port> ping`
- If password required: `redis-cli -h <redis_host> -p <redis_port> -a <password> ping`

#### Default admin password not working
- Default credentials: `admin/admin`
- If changed, check `/opt/jumpserver-installer-*/config.txt` or database
- Reset password: Access database and update `jms_user` table, or reinstall JumpServer

## Examples

### Testing Environment Configuration

**Option 1: Using auto-uploaded SSH key (recommended)**
```hcl
# Place your SSH public key at ~/.ssh/jump-{environment}.pub (e.g., ~/.ssh/jump-production.pub)
# It will be automatically uploaded as EC2 Key Pair named: devops-jump-testing (or <project>-jump-<environment> if project is overridden)
environment = "testing"
region      = "ap-southeast-1"
instance_type = "t3.micro"
# key_name is optional - will use auto-uploaded key if ~/.ssh/jump-{environment}.pub exists
enable_monitoring = false
ebs_volume_size = 8
enable_termination_protection = false
```

**Option 2: Using manually specified key**
```hcl
environment = "testing"
region      = "ap-southeast-1"
instance_type = "t3.micro"
key_name   = "my-ec2-key"  # Existing EC2 Key Pair name
enable_monitoring = false
ebs_volume_size = 8
enable_termination_protection = false
```

### Production Environment Configuration
```hcl
environment                 = "production"
region                      = "ap-southeast-1"
instance_type              = "t3.small"
key_name                   = "my-ec2-key"
enable_monitoring          = true
ebs_volume_size            = 20
enable_termination_protection = true
hostname                   = "jump-production"
cost_center                = "operations"
```

### Multiple Instances Configuration
```hcl
instance_count = 2

instance_defaults = {
  instance_type                 = "t3.small"
  key_name                      = "my-ec2-key"
  hostname_prefix               = "jump"
  enable_monitoring             = true
  ebs_volume_size               = 20
  ebs_volume_type               = "gp3"
  ebs_encrypted                 = true
  enable_termination_protection = true
}

instance_overrides = {
  "jump-production-1" = {
    instance_type = "t3.medium"
  }
}
```

### JumpServer Configuration Example

#### Basic JumpServer with Local Database/Redis
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
```

#### JumpServer with External RDS and ElastiCache
```hcl
jumpserver_enabled = true
jumpserver_db_host = "jumpserver-db.xxxxx.ap-southeast-1.rds.amazonaws.com"
jumpserver_db_port = 3306
jumpserver_db_user = "jumpserver"
jumpserver_db_password = "your-secure-password"
jumpserver_db_name = "jumpserver"

jumpserver_redis_host = "jumpserver-redis.xxxxx.cache.amazonaws.com"
jumpserver_redis_port = 6379
jumpserver_redis_password = "your-redis-password"

instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
enable_monitoring = true
```

#### JumpServer with Custom Keys and Ports
```hcl
jumpserver_enabled = true
jumpserver_version = "v2.28.8"
jumpserver_secret_key = "your-50-character-secret-key-here"
jumpserver_bootstrap_token = "your-24-character-token"
jumpserver_db_password = "your-secure-password"
jumpserver_http_port = 8080
jumpserver_ssh_port = 2222
jumpserver_rdp_port = 3389
jumpserver_log_level = "INFO"
```

#### Disable JumpServer (Plain Jump Server)
```hcl
jumpserver_enabled = false
instance_type = "t3.micro"
ebs_volume_size = 8
```

#### JumpServer with EKS Access
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
iam_instance_profile_enabled = true
enable_eks = true  # Enable EKS access permissions
instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
```

**Note**: After deployment, configure kubectl on the jump server:
```bash
# If using auto-uploaded key from ~/.ssh/jump-{environment}.pub:
ssh -i ~/.ssh/jump-{environment} ubuntu@<jump-server-ip>

# Or if using manually specified key:
ssh -i ~/.ssh/your-key.pem ubuntu@<jump-server-ip>

# Then configure kubectl:
aws eks update-kubeconfig --name <cluster-name> --region ap-southeast-1
kubectl get nodes
kubectl get pods -A
```

**Permissions granted when `enable_eks = true`**:
- EKS: DescribeCluster, ListClusters, AccessKubernetesApi
- EKS: DescribeNodegroup, ListNodegroups
- EKS: DescribeAddon, ListAddons
- EKS: DescribeAccessEntry, ListAccessEntries (for access entry management)

**Important**: 
- Ensure EKS cluster security group allows inbound traffic from jump server security group (check `terraform output jump_security_group_id`)
- EKS Access Entry must be configured in EKS module for kubectl access (see `terraform/eks/eks-access-entry.tf`)

#### JumpServer with External IAM Policies
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
iam_instance_profile_enabled = true

# Attach external IAM policies (AWS managed or custom policies)
ec2_external_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  "arn:aws:iam::123456789012:policy/MyCustomPolicy"
]

# Or use iam_role_policy_arns (same functionality)
# iam_role_policy_arns = [
#   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# ]

instance_type = "t3.large"
ebs_volume_size = 60
```

#### JumpServer with ECR Access
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
iam_instance_profile_enabled = true
enable_ecr = true  # Enable ECR access permissions
instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
```

**Note**: After deployment, you can use ECR from the jump server:
```bash
# SSH to jump server
ssh -i ~/.ssh/jump-{environment} ubuntu@<jump-server-ip>

# Login to ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com

# Pull image
docker pull <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<repository>:<tag>

# Push image
docker tag <image> <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<repository>:<tag>
docker push <account-id>.dkr.ecr.ap-southeast-1.amazonaws.com/<repository>:<tag>

# List repositories
aws ecr describe-repositories

# List images in a repository
aws ecr list-images --repository-name <repository-name>
```

**Permissions granted when `enable_ecr = true`**:
- ECR: GetAuthorizationToken (for Docker login)
- ECR: BatchCheckLayerAvailability, GetDownloadUrlForLayer, BatchGetImage (for pulling images)
- ECR: PutImage, InitiateLayerUpload, UploadLayerPart, CompleteLayerUpload (for pushing images)
- ECR: DescribeRepositories, ListImages, DescribeImages (for repository management)
- ECR: CreateRepository, DeleteRepository (for repository management)

#### JumpServer with RDS Access
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
iam_instance_profile_enabled = true
enable_rds = true  # Enable RDS and Secrets Manager access
instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
```

**Note**: After deployment, you can access RDS secrets from the jump server:
```bash
# SSH to jump server
ssh -i ~/.ssh/jump-{environment} ubuntu@<jump-server-ip>

# Get RDS master password from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id arn:aws:secretsmanager:ap-southeast-1:xxxxx:secret:web3-production-rds-master-password-tl1WvX \
  --query SecretString --output text | jq .

# Or get password only
aws secretsmanager get-secret-value \
  --secret-id arn:aws:secretsmanager:ap-southeast-1:xxxxx:secret:web3-production-rds-master-password-tl1WvX \
  --query SecretString --output text | jq -r .password

# List all RDS-related secrets
aws secretsmanager list-secrets --query "SecretList[?contains(Name, 'rds') && contains(Name, 'master') && contains(Name, 'password')]"
```

**Permissions granted when `enable_rds = true`**:
- RDS: Describe DB instances, clusters, and endpoints
- Secrets Manager: GetSecretValue, DescribeSecret for RDS master password secrets
- KMS: Decrypt secrets encrypted by Secrets Manager

#### JumpServer with ElastiCache Access
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
iam_instance_profile_enabled = true
enable_elasticache = true  # Enable ElastiCache access permissions
instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
```

**Note**: After deployment, you can access ElastiCache from the jump server:
```bash
# SSH to jump server
ssh -i ~/.ssh/jump-{environment} ubuntu@<jump-server-ip>

# List ElastiCache clusters
aws elasticache describe-cache-clusters

# Describe a specific cluster
aws elasticache describe-cache-clusters --cache-cluster-id <cluster-id>

# List replication groups
aws elasticache describe-replication-groups

# Describe cache nodes
aws elasticache describe-cache-nodes --cache-cluster-id <cluster-id>

# List cache parameter groups
aws elasticache describe-cache-parameter-groups

# Describe events
aws elasticache describe-events --duration 60
```

**Permissions granted when `enable_elasticache = true`**:
- ElastiCache: DescribeCacheClusters, DescribeReplicationGroups, DescribeCacheNodes
- ElastiCache: DescribeCacheParameterGroups, DescribeCacheParameters
- ElastiCache: DescribeCacheSubnetGroups, DescribeEvents
- ElastiCache: ListTagsForResource

#### JumpServer with Multiple Services Access
```hcl
jumpserver_enabled = true
jumpserver_db_password = "your-secure-password"
iam_instance_profile_enabled = true
enable_rds = true          # Enable RDS and Secrets Manager access
enable_ecr = true          # Enable ECR access
enable_eks = true          # Enable EKS access
enable_elasticache = true # Enable ElastiCache access
instance_type = "t3.large"  # JumpServer minimum: 2 vCPU, 8GB RAM
ebs_volume_size = 60  # JumpServer minimum: 60GB HDD
```

This configuration enables access to RDS, ECR, EKS, and ElastiCache services from the jump server.

## Post-Deployment Tasks

1. **SSH Access**: 
   - Verify SSH access to the instance
   - Update SSH config if needed (see `zzz_reminder_access_commands` output)

2. **JumpServer Setup** (if enabled):
   - Access JumpServer web UI using the URL from outputs
   - Change default admin password immediately
   - Configure users, assets, and permissions

3. **IAM Permissions**:
   - Verify IAM instance profile is attached correctly
   - Test service access (RDS, ECR, EKS, ElastiCache) if enabled

4. **DNS Records** (if enabled):
   - Verify DNS records are created correctly
   - Test DNS resolution

## Troubleshooting

### Common Issues

1. **Cannot SSH to instance**: 
   - Verify security group allows SSH from your IP (check VPC allowlist)
   - Ensure EC2 Key Pair is correctly configured
   - Check CloudWatch logs for user data script execution

2. **Instance not getting public IP**: 
   - Verify the subnet is a public subnet (has route to Internet Gateway)
   - Check `associate_public_ip_address` is set to `true` (default)

3. **JumpServer not starting**: 
   - Check installation logs: `/var/log/jumpserver-install.log`
   - Verify database connectivity (if using external database)
   - Check Docker status: `systemctl status docker`
   - View JumpServer logs: `cd /opt/jumpserver-installer-* && ./jmsctl.sh logs`

4. **DNS records not created**: 
   - Verify Route53 hosted zone exists
   - Check `domain` variable matches VPC module domain
   - Verify `dns_enabled = true`

## Contributing

Contributions are welcome! Please ensure:

1. Code follows Terraform best practices
2. All variables have descriptions
3. Examples are updated
4. Documentation is kept up to date

## License

This module is licensed under the Apache License 2.0. See [LICENSE](../LICENSE) for details.

## References

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS EC2 Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-best-practices.html)
- [JumpServer Documentation](https://docs.jumpserver.org/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_autoscaling_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ebs_volume.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_elb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb) | resource |
| [aws_iam_instance_profile.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_cloudwatch_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_ec2_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_ecr_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_ecs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_eks_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_elasticache_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.main_rds_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.main_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.main_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main_cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.project_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.elb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_to_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.elb_to_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_volume_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [local_file.ssh_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.jump_db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.jump_redis](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.amazon_linux_2023_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.debian_11_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.debian_12_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.rhel_8_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.rhel_9_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.ubuntu_24_04_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [local_file.ssh_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_ebs_volumes"></a> [additional\_ebs\_volumes](#input\_additional\_ebs\_volumes) | Map of additional EBS volumes to attach to instances. Key format: '{instance\_name}.{volume\_name}'. Example: { 'web-1.data' => { size = 100, type = 'gp3' } } | <pre>map(object({<br/>    size        = number<br/>    type        = optional(string, "gp3")<br/>    encrypted   = optional(bool, true)<br/>    kms_key_id  = optional(string, null)<br/>    device_name = optional(string, null)<br/>    tags        = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | ARN of SSL certificate for HTTPS listener (required if alb\_protocol is HTTPS) | `string` | `null` | no |
| <a name="input_alb_enable_deletion_protection"></a> [alb\_enable\_deletion\_protection](#input\_alb\_enable\_deletion\_protection) | Enable deletion protection for ALB | `bool` | `false` | no |
| <a name="input_alb_health_check_healthy_threshold"></a> [alb\_health\_check\_healthy\_threshold](#input\_alb\_health\_check\_healthy\_threshold) | Number of consecutive successful health checks before marking target as healthy | `number` | `2` | no |
| <a name="input_alb_health_check_interval"></a> [alb\_health\_check\_interval](#input\_alb\_health\_check\_interval) | Health check interval in seconds for ALB | `number` | `30` | no |
| <a name="input_alb_health_check_path"></a> [alb\_health\_check\_path](#input\_alb\_health\_check\_path) | Health check path for ALB target group | `string` | `"/"` | no |
| <a name="input_alb_health_check_port"></a> [alb\_health\_check\_port](#input\_alb\_health\_check\_port) | Health check port for ALB target group | `number` | `null` | no |
| <a name="input_alb_health_check_protocol"></a> [alb\_health\_check\_protocol](#input\_alb\_health\_check\_protocol) | Health check protocol for ALB target group (HTTP or HTTPS) | `string` | `"HTTP"` | no |
| <a name="input_alb_health_check_timeout"></a> [alb\_health\_check\_timeout](#input\_alb\_health\_check\_timeout) | Health check timeout in seconds for ALB | `number` | `5` | no |
| <a name="input_alb_health_check_unhealthy_threshold"></a> [alb\_health\_check\_unhealthy\_threshold](#input\_alb\_health\_check\_unhealthy\_threshold) | Number of consecutive failed health checks before marking target as unhealthy | `number` | `2` | no |
| <a name="input_alb_ingress_cidr_blocks"></a> [alb\_ingress\_cidr\_blocks](#input\_alb\_ingress\_cidr\_blocks) | CIDR blocks allowed to reach the ALB security group. Empty by default — must be set when enable\_alb is true. Production forbids 0.0.0.0/0 unless allow\_public\_lb\_ingress = true. | `list(string)` | `[]` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Whether the ALB is internal (true) or internet-facing (false) | `bool` | `false` | no |
| <a name="input_alb_port"></a> [alb\_port](#input\_alb\_port) | Port for ALB listener | `number` | `80` | no |
| <a name="input_alb_protocol"></a> [alb\_protocol](#input\_alb\_protocol) | Protocol for ALB listener (HTTP or HTTPS) | `string` | `"HTTP"` | no |
| <a name="input_alb_subnet_type"></a> [alb\_subnet\_type](#input\_alb\_subnet\_type) | Subnet type for ALB (public, private, database). Defaults to public for internet-facing, private for internal | `string` | `null` | no |
| <a name="input_alb_target_port"></a> [alb\_target\_port](#input\_alb\_target\_port) | Target port on EC2 instances for ALB | `number` | `80` | no |
| <a name="input_alb_target_protocol"></a> [alb\_target\_protocol](#input\_alb\_target\_protocol) | Target protocol for ALB (HTTP or HTTPS) | `string` | `"HTTP"` | no |
| <a name="input_allow_public_lb_ingress"></a> [allow\_public\_lb\_ingress](#input\_allow\_public\_lb\_ingress) | Explicitly allow 0.0.0.0/0 (or ::/0) on ALB/ELB. Required in production when using public CIDRs. | `bool` | `false` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID to use for instances. If not specified, will use Ubuntu 24.04 LTS from SSM Parameter Store | `string` | `null` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | AMI name filter for AMI lookup. Used when ami\_id is not specified | `string` | `"ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | AMI owner for AMI lookup (e.g., '099720109477' for Canonical/Ubuntu, 'amazon' for Amazon Linux) | `string` | `"099720109477"` | no |
| <a name="input_asg_default_cooldown"></a> [asg\_default\_cooldown](#input\_asg\_default\_cooldown) | Default cooldown period in seconds | `number` | `300` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | Desired number of instances in the Auto Scaling Group | `number` | `1` | no |
| <a name="input_asg_health_check_grace_period"></a> [asg\_health\_check\_grace\_period](#input\_asg\_health\_check\_grace\_period) | Health check grace period in seconds | `number` | `300` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | Health check type for ASG. Options: EC2, ELB | `string` | `"EC2"` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum number of instances in the Auto Scaling Group | `number` | `3` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Minimum number of instances in the Auto Scaling Group | `number` | `1` | no |
| <a name="input_asg_tags"></a> [asg\_tags](#input\_asg\_tags) | Additional tags for ASG instances | `map(string)` | `{}` | no |
| <a name="input_asg_termination_policies"></a> [asg\_termination\_policies](#input\_asg\_termination\_policies) | List of termination policies for ASG | `list(string)` | <pre>[<br/>  "Default"<br/>]</pre> | no |
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | IAM role ARN to assume for cross-account access (optional) | `string` | `null` | no |
| <a name="input_assume_role_external_id"></a> [assume\_role\_external\_id](#input\_assume\_role\_external\_id) | External ID to use when assuming role (optional) | `string` | `null` | no |
| <a name="input_assume_role_session_name"></a> [assume\_role\_session\_name](#input\_assume\_role\_session\_name) | Session name to use when assuming role | `string` | `"terraform-ec2"` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Enable CloudWatch Logs for instances. When enabled, creates log groups and configures log streaming. | `bool` | `false` | no |
| <a name="input_cloudwatch_logs_group_name"></a> [cloudwatch\_logs\_group\_name](#input\_cloudwatch\_logs\_group\_name) | Name of the CloudWatch Logs group. If not specified, uses {name\_prefix}-{environment}-logs | `string` | `null` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | Number of days to retain CloudWatch logs. Options: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, or 0 (never expire) | `number` | `7` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Enable custom CloudWatch metrics collection. When enabled, installs CloudWatch agent and configures metrics. | `bool` | `false` | no |
| <a name="input_code"></a> [code](#input\_code) | Code repository and path (e.g., 'reponame:path/to/terraform/ec2') | `string` | `""` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center for cost allocation | `string` | `null` | no |
| <a name="input_database_subnet_ids"></a> [database\_subnet\_ids](#input\_database\_subnet\_ids) | Database subnet IDs when not using VPC remote state | `list(string)` | `[]` | no |
| <a name="input_dns_enabled"></a> [dns\_enabled](#input\_dns\_enabled) | Enable Route53 DNS records for instances | `bool` | `false` | no |
| <a name="input_dns_record_format"></a> [dns\_record\_format](#input\_dns\_record\_format) | Format for DNS record names. Variables: {name\_prefix}, {index}, {environment}, {domain}. Default: '{name\_prefix}-{index}.{environment}.{domain}' | `string` | `null` | no |
| <a name="input_dns_ttl"></a> [dns\_ttl](#input\_dns\_ttl) | TTL for Route53 DNS records in seconds. Lower TTL (60-120 seconds) ensures faster DNS updates when instance IP changes. | `number` | `60` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Base domain for DNS records (e.g., example.com). If VPC remote state has a domain configured, it will be used; otherwise this default will be used. | `string` | `null` | no |
| <a name="input_ebs_encrypted"></a> [ebs\_encrypted](#input\_ebs\_encrypted) | Enable encryption for EBS volume | `bool` | `true` | no |
| <a name="input_ebs_kms_key_id"></a> [ebs\_kms\_key\_id](#input\_ebs\_kms\_key\_id) | KMS key ID for EBS encryption (optional, uses default if not specified) | `string` | `null` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | Size of the EBS root volume in GB. Minimum 60GB recommended when jump server is enabled, 100GB when GitLab is enabled | `number` | `null` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | Type of EBS volume (gp3, gp2, io1, io2) | `string` | `"gp3"` | no |
| <a name="input_ec2_external_policy_arns"></a> [ec2\_external\_policy\_arns](#input\_ec2\_external\_policy\_arns) | List of external IAM policy ARNs to attach to the IAM role. This is an alias for iam\_role\_policy\_arns for clarity when attaching external policies. | `list(string)` | `[]` | no |
| <a name="input_elb_certificate_id"></a> [elb\_certificate\_id](#input\_elb\_certificate\_id) | ARN of SSL certificate for HTTPS/SSL listener (required if elb\_listener\_protocol is HTTPS or SSL) | `string` | `null` | no |
| <a name="input_elb_connection_draining"></a> [elb\_connection\_draining](#input\_elb\_connection\_draining) | Enable connection draining for ELB | `bool` | `true` | no |
| <a name="input_elb_connection_draining_timeout"></a> [elb\_connection\_draining\_timeout](#input\_elb\_connection\_draining\_timeout) | Connection draining timeout in seconds for ELB | `number` | `300` | no |
| <a name="input_elb_cross_zone_load_balancing"></a> [elb\_cross\_zone\_load\_balancing](#input\_elb\_cross\_zone\_load\_balancing) | Enable cross-zone load balancing for ELB | `bool` | `true` | no |
| <a name="input_elb_health_check_healthy_threshold"></a> [elb\_health\_check\_healthy\_threshold](#input\_elb\_health\_check\_healthy\_threshold) | Number of consecutive successful health checks before marking instance as healthy | `number` | `2` | no |
| <a name="input_elb_health_check_interval"></a> [elb\_health\_check\_interval](#input\_elb\_health\_check\_interval) | Health check interval in seconds for ELB | `number` | `30` | no |
| <a name="input_elb_health_check_target"></a> [elb\_health\_check\_target](#input\_elb\_health\_check\_target) | Health check target for ELB (e.g., HTTP:80/health or TCP:80) | `string` | `"HTTP:80/"` | no |
| <a name="input_elb_health_check_timeout"></a> [elb\_health\_check\_timeout](#input\_elb\_health\_check\_timeout) | Health check timeout in seconds for ELB | `number` | `5` | no |
| <a name="input_elb_health_check_unhealthy_threshold"></a> [elb\_health\_check\_unhealthy\_threshold](#input\_elb\_health\_check\_unhealthy\_threshold) | Number of consecutive failed health checks before marking instance as unhealthy | `number` | `2` | no |
| <a name="input_elb_idle_timeout"></a> [elb\_idle\_timeout](#input\_elb\_idle\_timeout) | Idle timeout in seconds for ELB | `number` | `60` | no |
| <a name="input_elb_ingress_cidr_blocks"></a> [elb\_ingress\_cidr\_blocks](#input\_elb\_ingress\_cidr\_blocks) | CIDR blocks allowed to reach the Classic ELB. Empty by default — must be set when enable\_elb is true. Production forbids 0.0.0.0/0 unless allow\_public\_lb\_ingress = true. | `list(string)` | `[]` | no |
| <a name="input_elb_instance_port"></a> [elb\_instance\_port](#input\_elb\_instance\_port) | Port on EC2 instances for ELB | `number` | `80` | no |
| <a name="input_elb_instance_protocol"></a> [elb\_instance\_protocol](#input\_elb\_instance\_protocol) | Protocol for ELB instance connection (HTTP, HTTPS, TCP, SSL) | `string` | `"HTTP"` | no |
| <a name="input_elb_internal"></a> [elb\_internal](#input\_elb\_internal) | Whether the ELB is internal (true) or internet-facing (false) | `bool` | `false` | no |
| <a name="input_elb_listener_port"></a> [elb\_listener\_port](#input\_elb\_listener\_port) | Port for ELB listener | `number` | `80` | no |
| <a name="input_elb_listener_protocol"></a> [elb\_listener\_protocol](#input\_elb\_listener\_protocol) | Protocol for ELB listener (HTTP, HTTPS, TCP, SSL) | `string` | `"HTTP"` | no |
| <a name="input_elb_subnet_type"></a> [elb\_subnet\_type](#input\_elb\_subnet\_type) | Subnet type for ELB (public, private, database). Defaults to public for internet-facing, private for internal | `string` | `null` | no |
| <a name="input_enable_alb"></a> [enable\_alb](#input\_enable\_alb) | Enable Application Load Balancer for EC2 instances | `bool` | `false` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable Auto Scaling Group for instances. When enabled, creates a Launch Template and ASG instead of individual EC2 instances. Note: When ASG is enabled, instance\_count and instances variables are ignored. | `bool` | `false` | no |
| <a name="input_enable_ecr"></a> [enable\_ecr](#input\_enable\_ecr) | Enable ECR access permissions. When enabled, allows EC2 instance to pull/push Docker images from/to ECR repositories. | `bool` | `false` | no |
| <a name="input_enable_ecs"></a> [enable\_ecs](#input\_enable\_ecs) | Enable ECS access permissions (describe/list by default; mutations optional). | `bool` | `false` | no |
| <a name="input_enable_eip"></a> [enable\_eip](#input\_enable\_eip) | Enable Elastic IP allocation for instances in public subnets. When enabled, each instance in a public subnet (associate\_public\_ip = true) will get a static public IP address. Useful for jump servers and other services that need a stable public IP. Note: Instances must be in public subnets for EIP to work. | `bool` | `false` | no |
| <a name="input_enable_eks"></a> [enable\_eks](#input\_enable\_eks) | Enable EKS access permissions. When enabled, allows EC2 instance to describe EKS clusters and configure kubectl access. | `bool` | `false` | no |
| <a name="input_enable_elasticache"></a> [enable\_elasticache](#input\_enable\_elasticache) | Enable ElastiCache access permissions. When enabled, allows EC2 instance to describe ElastiCache clusters and nodes. | `bool` | `false` | no |
| <a name="input_enable_elb"></a> [enable\_elb](#input\_enable\_elb) | Enable Classic Load Balancer (ELB) for EC2 instances | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable IPv6 support for EC2 instances. Requires subnet to have IPv6 CIDR block assigned. | `bool` | `false` | no |
| <a name="input_enable_jump"></a> [enable\_jump](#input\_enable\_jump) | Enable jump server deployment on instances. When enabled, automatically deploys jump server via userdata and configures security group rules | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable detailed CloudWatch monitoring (costs extra, basic monitoring is free) | `bool` | `false` | no |
| <a name="input_enable_rds"></a> [enable\_rds](#input\_enable\_rds) | Enable RDS access permissions (Secrets Manager and RDS describe). When enabled, allows EC2 instance to access RDS secrets and describe RDS instances. | `bool` | `false` | no |
| <a name="input_enable_ssm_session_manager"></a> [enable\_ssm\_session\_manager](#input\_enable\_ssm\_session\_manager) | Enable AWS Systems Manager Session Manager for secure, SSH-free access to instances. When enabled, automatically attaches AmazonSSMManagedInstanceCore policy and ensures SSM Agent is running. This provides a more secure alternative to SSH. | `bool` | `false` | no |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | Enable termination protection for the instance | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_gitlab_enabled"></a> [gitlab\_enabled](#input\_gitlab\_enabled) | Enable GitLab CE installation on instances. When enabled, automatically deploys GitLab via userdata and configures security group rules | `bool` | `false` | no |
| <a name="input_gitlab_external_url"></a> [gitlab\_external\_url](#input\_gitlab\_external\_url) | GitLab external URL (e.g., http://gitlab.example.com or https://gitlab.example.com). Used for GitLab configuration | `string` | `"http://gitlab.example.com"` | no |
| <a name="input_gitlab_http_port"></a> [gitlab\_http\_port](#input\_gitlab\_http\_port) | GitLab HTTP port | `number` | `80` | no |
| <a name="input_gitlab_https_port"></a> [gitlab\_https\_port](#input\_gitlab\_https\_port) | GitLab HTTPS port | `number` | `443` | no |
| <a name="input_gitlab_ssh_port"></a> [gitlab\_ssh\_port](#input\_gitlab\_ssh\_port) | GitLab SSH port (for Git operations) | `number` | `22` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname prefix for instances (optional, use instances variable or instance\_defaults.hostname\_prefix instead) | `string` | `null` | no |
| <a name="input_iam_cloudwatch_log_group_arns"></a> [iam\_cloudwatch\_log\_group\_arns](#input\_iam\_cloudwatch\_log\_group\_arns) | CloudWatch Logs ARNs for ECS log read. Empty defaults to /{project}/*. | `list(string)` | `[]` | no |
| <a name="input_iam_ecr_allow_push"></a> [iam\_ecr\_allow\_push](#input\_iam\_ecr\_allow\_push) | Allow ECR push actions in addition to pull. | `bool` | `false` | no |
| <a name="input_iam_ecr_repository_arns"></a> [iam\_ecr\_repository\_arns](#input\_iam\_ecr\_repository\_arns) | ECR repository ARNs. Empty defaults to repository/{project}-*. | `list(string)` | `[]` | no |
| <a name="input_iam_ecs_allow_mutations"></a> [iam\_ecs\_allow\_mutations](#input\_iam\_ecs\_allow\_mutations) | Allow ECS service/task-definition create/update/delete (off by default). | `bool` | `false` | no |
| <a name="input_iam_ecs_allow_task_run"></a> [iam\_ecs\_allow\_task\_run](#input\_iam\_ecs\_allow\_task\_run) | Allow ecs:RunTask / StopTask on scoped task definitions. | `bool` | `false` | no |
| <a name="input_iam_ecs_cluster_arns"></a> [iam\_ecs\_cluster\_arns](#input\_iam\_ecs\_cluster\_arns) | ECS cluster ARNs. Empty defaults to cluster/{project}-*. | `list(string)` | `[]` | no |
| <a name="input_iam_ecs_service_arns"></a> [iam\_ecs\_service\_arns](#input\_iam\_ecs\_service\_arns) | ECS service ARNs. Empty defaults to service/{project}-*/*. | `list(string)` | `[]` | no |
| <a name="input_iam_ecs_task_definition_arns"></a> [iam\_ecs\_task\_definition\_arns](#input\_iam\_ecs\_task\_definition\_arns) | ECS task definition ARNs. Empty defaults to task-definition/{project}-*:*. | `list(string)` | `[]` | no |
| <a name="input_iam_eks_cluster_arns"></a> [iam\_eks\_cluster\_arns](#input\_iam\_eks\_cluster\_arns) | EKS cluster ARNs. Empty defaults to cluster/{project}-*. | `list(string)` | `[]` | no |
| <a name="input_iam_enable_ec2_describe"></a> [iam\_enable\_ec2\_describe](#input\_iam\_enable\_ec2\_describe) | Attach read-only EC2 Describe* policy (Resource=* required by AWS for these APIs). | `bool` | `true` | no |
| <a name="input_iam_instance_profile_enabled"></a> [iam\_instance\_profile\_enabled](#input\_iam\_instance\_profile\_enabled) | Enable IAM instance profile for AWS service access (RDS, ElastiCache, ECR, EKS, ECS, etc.) | `bool` | `false` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name of existing IAM instance profile to attach. If specified, iam\_instance\_profile\_enabled must be true and custom IAM role/policies will not be created | `string` | `null` | no |
| <a name="input_iam_kms_key_arns"></a> [iam\_kms\_key\_arns](#input\_iam\_kms\_key\_arns) | KMS key ARNs for Secrets Manager decrypt. Empty defaults to account keys in region. | `list(string)` | `[]` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name for the IAM role (when creating new role). Defaults to {name\_prefix}-{environment}-role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Map of additional IAM policies to attach to the IAM role. Format: { policy\_name => policy\_json } | `map(string)` | `{}` | no |
| <a name="input_iam_role_policy_arns"></a> [iam\_role\_policy\_arns](#input\_iam\_role\_policy\_arns) | List of IAM policy ARNs to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_secrets_arns"></a> [iam\_secrets\_arns](#input\_iam\_secrets\_arns) | Secrets Manager ARNs the instance may read. Empty uses project/environment + rds* patterns. | `list(string)` | `[]` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of EC2 instances to create. If set, instances will be generated automatically using instance\_defaults. The instances map will use hostname as the key (e.g., 'ec2-production-1', 'ec2-production-2'). Recommended approach for multiple instances. | `number` | `0` | no |
| <a name="input_instance_defaults"></a> [instance\_defaults](#input\_instance\_defaults) | Default configuration for instances when using instance\_count. Individual instances can override these defaults via instance\_overrides. | <pre>object({<br/>    instance_type                 = optional(string, null)<br/>    key_name                      = optional(string, null)<br/>    hostname_prefix               = optional(string, null)<br/>    subnet_id                     = optional(string, null)<br/>    subnet_type                   = optional(string, null)<br/>    associate_public_ip           = optional(bool, null)<br/>    enable_monitoring             = optional(bool, false)<br/>    ebs_volume_size               = optional(number, null)<br/>    ebs_volume_type               = optional(string, "gp3")<br/>    ebs_encrypted                 = optional(bool, true)<br/>    ebs_kms_key_id                = optional(string, null)<br/>    enable_termination_protection = optional(bool, false)<br/>    metadata_options = optional(object({<br/>      http_endpoint               = optional(string, "enabled")<br/>      http_tokens                 = optional(string, "required")<br/>      http_put_response_hop_limit = optional(number, 2)<br/>      instance_metadata_tags      = optional(string, "enabled")<br/>    }), {})<br/>    user_data                   = optional(string, null)<br/>    user_data_replace_on_change = optional(bool, true)<br/>    tags                        = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_instance_overrides"></a> [instance\_overrides](#input\_instance\_overrides) | Map of instance-specific overrides. Key is hostname, value is instance configuration object that will override instance\_defaults. | <pre>map(object({<br/>    instance_type                 = optional(string, null)<br/>    key_name                      = optional(string, null)<br/>    subnet_id                     = optional(string, null)<br/>    subnet_type                   = optional(string, null)<br/>    associate_public_ip           = optional(bool, null)<br/>    enable_monitoring             = optional(bool, null)<br/>    ebs_volume_size               = optional(number, null)<br/>    ebs_volume_type               = optional(string, null)<br/>    ebs_encrypted                 = optional(bool, null)<br/>    ebs_kms_key_id                = optional(string, null)<br/>    enable_termination_protection = optional(bool, null)<br/>    metadata_options = optional(object({<br/>      http_endpoint               = optional(string, "enabled")<br/>      http_tokens                 = optional(string, "required")<br/>      http_put_response_hop_limit = optional(number, 2)<br/>      instance_metadata_tags      = optional(string, "enabled")<br/>    }), null)<br/>    user_data                   = optional(string, null)<br/>    user_data_replace_on_change = optional(bool, null)<br/>    tags                        = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type. Defaults to t3.micro for general use, t3.medium when jump server is enabled, t3.large when GitLab is enabled | `string` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Map of instance configurations. Key is instance name, value is instance configuration object. Use instance\_count and instance\_defaults instead. | <pre>map(object({<br/>    instance_type                 = optional(string, null)<br/>    key_name                      = optional(string, null)<br/>    hostname                      = optional(string, null)<br/>    subnet_id                     = optional(string, null)<br/>    subnet_type                   = optional(string, null)<br/>    associate_public_ip           = optional(bool, null)<br/>    enable_monitoring             = optional(bool, false)<br/>    ebs_volume_size               = optional(number, null)<br/>    ebs_volume_type               = optional(string, "gp3")<br/>    ebs_encrypted                 = optional(bool, true)<br/>    ebs_kms_key_id                = optional(string, null)<br/>    enable_termination_protection = optional(bool, false)<br/>    metadata_options = optional(object({<br/>      http_endpoint               = optional(string, "enabled")<br/>      http_tokens                 = optional(string, "required")<br/>      http_put_response_hop_limit = optional(number, 2)<br/>      instance_metadata_tags      = optional(string, "enabled")<br/>    }), {})<br/>    user_data                   = optional(string, null)<br/>    user_data_replace_on_change = optional(bool, true)<br/>    tags                        = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_ipv6_address_count"></a> [ipv6\_address\_count](#input\_ipv6\_address\_count) | Number of IPv6 addresses to assign to each instance. Requires enable\_ipv6 = true | `number` | `1` | no |
| <a name="input_jump_bootstrap_token"></a> [jump\_bootstrap\_token](#input\_jump\_bootstrap\_token) | Jump server BOOTSTRAP\_TOKEN (24+ characters). If not provided, will be auto-generated | `string` | `null` | no |
| <a name="input_jump_db_host"></a> [jump\_db\_host](#input\_jump\_db\_host) | Jump server database host (use 'localhost' for local MySQL, or RDS endpoint for external database) | `string` | `"localhost"` | no |
| <a name="input_jump_db_name"></a> [jump\_db\_name](#input\_jump\_db\_name) | Jump server database name | `string` | `"jumpserver"` | no |
| <a name="input_jump_db_password"></a> [jump\_db\_password](#input\_jump\_db\_password) | Jump server database password. If not provided and enable\_jump is true, a random password will be auto-generated. | `string` | `null` | no |
| <a name="input_jump_db_port"></a> [jump\_db\_port](#input\_jump\_db\_port) | Jump server database port | `number` | `3306` | no |
| <a name="input_jump_db_user"></a> [jump\_db\_user](#input\_jump\_db\_user) | Jump server database user | `string` | `"root"` | no |
| <a name="input_jump_docker_subnet"></a> [jump\_docker\_subnet](#input\_jump\_docker\_subnet) | Jump server Docker subnet CIDR | `string` | `"192.168.250.0/24"` | no |
| <a name="input_jump_http_port"></a> [jump\_http\_port](#input\_jump\_http\_port) | Jump server HTTP port | `number` | `80` | no |
| <a name="input_jump_log_level"></a> [jump\_log\_level](#input\_jump\_log\_level) | Jump server log level (ERROR, WARNING, INFO, DEBUG) | `string` | `"ERROR"` | no |
| <a name="input_jump_rdp_port"></a> [jump\_rdp\_port](#input\_jump\_rdp\_port) | Jump server RDP port | `number` | `3389` | no |
| <a name="input_jump_redis_host"></a> [jump\_redis\_host](#input\_jump\_redis\_host) | Jump server Redis host (use 'localhost' for local Redis, or ElastiCache endpoint for external Redis) | `string` | `"localhost"` | no |
| <a name="input_jump_redis_password"></a> [jump\_redis\_password](#input\_jump\_redis\_password) | Jump server Redis password. If not provided and enable\_jump is true, a random password will be auto-generated. Set to empty string to disable password. | `string` | `null` | no |
| <a name="input_jump_redis_port"></a> [jump\_redis\_port](#input\_jump\_redis\_port) | Jump server Redis port | `number` | `6379` | no |
| <a name="input_jump_secret_key"></a> [jump\_secret\_key](#input\_jump\_secret\_key) | Jump server SECRET\_KEY (50+ characters). If not provided, will be auto-generated | `string` | `null` | no |
| <a name="input_jump_ssh_port"></a> [jump\_ssh\_port](#input\_jump\_ssh\_port) | Jump server SSH port | `number` | `22` | no |
| <a name="input_jump_version"></a> [jump\_version](#input\_jump\_version) | Jump server version to install (e.g., v2.28.8) | `string` | `"v2.28.8"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the AWS EC2 Key Pair to use for SSH access (optional: if key\_path is provided and file exists, it will be automatically uploaded and used as default) | `string` | `null` | no |
| <a name="input_key_path"></a> [key\_path](#input\_key\_path) | Path to SSH public key file (e.g., ~/.ssh/ec2-production.pub). If provided and file exists with non-empty content, will automatically create EC2 Key Pair. Recommended format: ~/.ssh/{name\_prefix}-{environment}.pub where {environment} matches the environment variable value | `string` | `null` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Instance metadata options | <pre>object({<br/>    http_endpoint               = optional(string, "enabled")<br/>    http_tokens                 = optional(string, "required")<br/>    http_put_response_hop_limit = optional(number, 2)<br/>    instance_metadata_tags      = optional(string, "enabled")<br/>  })</pre> | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names (e.g., 'web', 'app', 'ec2'). Defaults to 'ec2' | `string` | `"ec2"` | no |
| <a name="input_netbird_enabled"></a> [netbird\_enabled](#input\_netbird\_enabled) | Enable NetBird VPN client installation on instances. When enabled, automatically installs NetBird and connects to the NetBird network using the setup key | `bool` | `false` | no |
| <a name="input_netbird_management_url"></a> [netbird\_management\_url](#input\_netbird\_management\_url) | NetBird management URL (optional). If not specified, uses the default NetBird cloud management. Use this if you have a self-hosted NetBird management server | `string` | `null` | no |
| <a name="input_netbird_setup_key"></a> [netbird\_setup\_key](#input\_netbird\_setup\_key) | NetBird setup key for connecting to the NetBird network. Required when netbird\_enabled is true. Get this from your NetBird Management Dashboard | `string` | `null` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type. Options: ubuntu, amazon-linux, rhel, debian | `string` | `"ubuntu"` | no |
| <a name="input_os_version"></a> [os\_version](#input\_os\_version) | Operating system version. For Ubuntu: 24.04. For Amazon Linux: 2023. For RHEL: 8 or 9. For Debian: 12 or 11 | `string` | `"24.04"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the resources | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs when not using VPC remote state | `list(string)` | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | `""` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet IDs when not using VPC remote state | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to instances. If not specified, uses VPC security group or creates new security group based on security\_group\_rules | `list(string)` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Map of security group rules to create a new security group. Format: { rule\_name => { type = "ingress"\|"egress", from\_port = 22, to\_port = 22, protocol = "tcp", cidr\_blocks = ["0.0.0.0/0"] } } | <pre>map(object({<br/>    type                     = string<br/>    from_port                = number<br/>    to_port                  = number<br/>    protocol                 = string<br/>    cidr_blocks              = optional(list(string), [])<br/>    ipv6_cidr_blocks         = optional(list(string), [])<br/>    prefix_list_ids          = optional(list(string), [])<br/>    source_security_group_id = optional(string, null)<br/>    description              = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_spot_instance_enabled"></a> [spot\_instance\_enabled](#input\_spot\_instance\_enabled) | Enable Spot instance for cost optimization. Spot instances can be interrupted with 2-minute notice. Not recommended for production workloads. | `bool` | `false` | no |
| <a name="input_spot_instance_type"></a> [spot\_instance\_type](#input\_spot\_instance\_type) | Instance type for Spot instance (optional). If not specified, uses the same instance\_type as on-demand instances. | `string` | `null` | no |
| <a name="input_spot_interruption_behavior"></a> [spot\_interruption\_behavior](#input\_spot\_interruption\_behavior) | Behavior when Spot instance is interrupted. Options: stop, terminate, hibernate | `string` | `"terminate"` | no |
| <a name="input_spot_max_price"></a> [spot\_max\_price](#input\_spot\_max\_price) | Maximum price per hour for Spot instance. If not specified, uses current Spot price. This is an alias for spot\_price for clarity. | `string` | `null` | no |
| <a name="input_spot_price"></a> [spot\_price](#input\_spot\_price) | Maximum price per hour for Spot instance (optional). If not specified, uses current Spot price. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for instances (if not specified, uses first public subnet from VPC). Use subnet\_type or subnet\_ids in instance configuration instead | `string` | `null` | no |
| <a name="input_subnet_type"></a> [subnet\_type](#input\_subnet\_type) | Subnet type to use when subnet\_id is not specified (public, private, database). Defaults to public | `string` | `"public"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_ubuntu_version"></a> [ubuntu\_version](#input\_ubuntu\_version) | Ubuntu version to use when using SSM Parameter Store (24.04). Only used when ami\_id is null and os\_type is ubuntu. Deprecated: use os\_type and os\_version instead | `string` | `"24.04"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data script content. If provided, overrides userdata\_script\_path. Can be used for custom initialization scripts | `string` | `null` | no |
| <a name="input_userdata_script_path"></a> [userdata\_script\_path](#input\_userdata\_script\_path) | Path to the userdata script file (relative to module root or absolute path). Used when enable\_jump is false. Use minimal version for EC2 to avoid 16KB limit. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID. Required when vpc\_remote\_state\_bucket is null. | `string` | `null` | no |
| <a name="input_vpc_remote_state_bucket"></a> [vpc\_remote\_state\_bucket](#input\_vpc\_remote\_state\_bucket) | S3 bucket for VPC remote state. Optional when vpc\_id and subnet IDs are passed directly. | `string` | `null` | no |
| <a name="input_vpc_remote_state_key"></a> [vpc\_remote\_state\_key](#input\_vpc\_remote\_state\_key) | Remote state key for VPC module. Must match the key in your VPC module's backend.tf configuration. Example: 'ACCOUNT/terraform-aws-modules:vpc/examples/basic/terraform.tfstate' | `string` | `"vpc/terraform.tfstate"` | no |
| <a name="input_vpc_remote_state_workspace_key_prefix"></a> [vpc\_remote\_state\_workspace\_key\_prefix](#input\_vpc\_remote\_state\_workspace\_key\_prefix) | Workspace key prefix for VPC remote state. Must match the workspace\_key\_prefix in your VPC module's backend.tf configuration. Example: 'env:development' or 'env:' | `string` | `"env:"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | ID of the Application Load Balancer |
| <a name="output_alb_listener_arn"></a> [alb\_listener\_arn](#output\_alb\_listener\_arn) | ARN of the ALB listener |
| <a name="output_alb_listener_id"></a> [alb\_listener\_id](#output\_alb\_listener\_id) | ID of the ALB listener |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ID of the ALB security group |
| <a name="output_alb_target_group_arn"></a> [alb\_target\_group\_arn](#output\_alb\_target\_group\_arn) | ARN of the ALB target group |
| <a name="output_alb_target_group_id"></a> [alb\_target\_group\_id](#output\_alb\_target\_group\_id) | ID of the ALB target group |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Zone ID of the Application Load Balancer |
| <a name="output_asg_arn"></a> [asg\_arn](#output\_asg\_arn) | ARN of the Auto Scaling Group (if enabled) |
| <a name="output_asg_desired_capacity"></a> [asg\_desired\_capacity](#output\_asg\_desired\_capacity) | Desired capacity of the Auto Scaling Group |
| <a name="output_asg_id"></a> [asg\_id](#output\_asg\_id) | ID of the Auto Scaling Group (if enabled) |
| <a name="output_asg_max_size"></a> [asg\_max\_size](#output\_asg\_max\_size) | Maximum size of the Auto Scaling Group |
| <a name="output_asg_min_size"></a> [asg\_min\_size](#output\_asg\_min\_size) | Minimum size of the Auto Scaling Group |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the Auto Scaling Group (if enabled) |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch Logs group (if enabled) |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Logs group (if enabled) |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the first EC2 instance |
| <a name="output_dns_name_private"></a> [dns\_name\_private](#output\_dns\_name\_private) | Private/internal DNS name of the first EC2 instance |
| <a name="output_dns_names"></a> [dns\_names](#output\_dns\_names) | Map of DNS names for EC2 instances |
| <a name="output_dns_names_private"></a> [dns\_names\_private](#output\_dns\_names\_private) | Map of private/internal DNS names for EC2 instances |
| <a name="output_ec2_name"></a> [ec2\_name](#output\_ec2\_name) | Name of the EC2 module (for reference) |
| <a name="output_elastic_ip_ids"></a> [elastic\_ip\_ids](#output\_elastic\_ip\_ids) | Map of Elastic IP allocation IDs by instance hostname (if enable\_eip is true) |
| <a name="output_elastic_ips"></a> [elastic\_ips](#output\_elastic\_ips) | Map of Elastic IP addresses by instance hostname (if enable\_eip is true) |
| <a name="output_elb_dns_name"></a> [elb\_dns\_name](#output\_elb\_dns\_name) | DNS name of the Classic Load Balancer |
| <a name="output_elb_id"></a> [elb\_id](#output\_elb\_id) | ID of the Classic Load Balancer |
| <a name="output_elb_name"></a> [elb\_name](#output\_elb\_name) | Name of the Classic Load Balancer |
| <a name="output_elb_security_group_id"></a> [elb\_security\_group\_id](#output\_elb\_security\_group\_id) | ID of the ELB security group |
| <a name="output_elb_source_security_group_id"></a> [elb\_source\_security\_group\_id](#output\_elb\_source\_security\_group\_id) | ID of the source security group for ELB |
| <a name="output_elb_zone_id"></a> [elb\_zone\_id](#output\_elb\_zone\_id) | Zone ID of the Classic Load Balancer |
| <a name="output_gitlab_access_url"></a> [gitlab\_access\_url](#output\_gitlab\_access\_url) | GitLab web access URL (HTTP/HTTPS) - uses external\_url if set, otherwise DNS name or IP address |
| <a name="output_gitlab_enabled"></a> [gitlab\_enabled](#output\_gitlab\_enabled) | Whether GitLab is enabled on the EC2 instance |
| <a name="output_gitlab_https_url"></a> [gitlab\_https\_url](#output\_gitlab\_https\_url) | GitLab HTTPS access URL - uses project-based DNS name (e.g., gitlab.production.example.com) if ALB and DNS are enabled with HTTPS, otherwise uses external\_url if it's HTTPS, otherwise null |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | Name of the IAM instance profile attached to instances |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role attached to instances |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | ARN of the first EC2 instance |
| <a name="output_instance_dns"></a> [instance\_dns](#output\_instance\_dns) | Public DNS name of the first EC2 instance |
| <a name="output_instance_elastic_ip"></a> [instance\_elastic\_ip](#output\_instance\_elastic\_ip) | Elastic IP address of the first EC2 instance (if enable\_eip is true) |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the first EC2 instance |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | Map of instance IDs by instance name |
| <a name="output_instance_ipv6_addresses"></a> [instance\_ipv6\_addresses](#output\_instance\_ipv6\_addresses) | IPv6 addresses of the first EC2 instance (if IPv6 enabled) |
| <a name="output_instance_ipv6_addresses_map"></a> [instance\_ipv6\_addresses\_map](#output\_instance\_ipv6\_addresses\_map) | Map of IPv6 addresses by instance name (if IPv6 enabled) |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | Private IP address of the first EC2 instance |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | Map of private IP addresses by instance name |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | Public IP address of the first EC2 instance (Elastic IP if enable\_eip is true, otherwise auto-assigned public IP) |
| <a name="output_instance_public_ips"></a> [instance\_public\_ips](#output\_instance\_public\_ips) | Map of public IP addresses by instance name (Elastic IP if enable\_eip is true, otherwise auto-assigned public IP) |
| <a name="output_instances"></a> [instances](#output\_instances) | Map of all EC2 instances (empty if ASG is enabled) |
| <a name="output_jump_access_url"></a> [jump\_access\_url](#output\_jump\_access\_url) | Jump server web access URL (HTTP) - uses DNS name if available, otherwise IP address |
| <a name="output_jump_admin_info"></a> [jump\_admin\_info](#output\_jump\_admin\_info) | Jump server Web UI admin credentials and access information |
| <a name="output_jump_bootstrap_token"></a> [jump\_bootstrap\_token](#output\_jump\_bootstrap\_token) | Jump server BOOTSTRAP\_TOKEN (sensitive, auto-generated on server if not provided) |
| <a name="output_jump_db_password"></a> [jump\_db\_password](#output\_jump\_db\_password) | Jump server database password (sensitive) |
| <a name="output_jump_dns_names"></a> [jump\_dns\_names](#output\_jump\_dns\_names) | [DEPRECATED] Map of DNS names for EC2 instances. Use dns\_names instead. |
| <a name="output_jump_enabled"></a> [jump\_enabled](#output\_jump\_enabled) | Whether jump server is enabled on the EC2 instance |
| <a name="output_jump_https_url"></a> [jump\_https\_url](#output\_jump\_https\_url) | Jump server HTTPS access URL - uses project-based DNS name (e.g., jump.production.example.com) if ALB and DNS are enabled with HTTPS, otherwise null |
| <a name="output_jump_instance_id"></a> [jump\_instance\_id](#output\_jump\_instance\_id) | [DEPRECATED] ID of the first EC2 instance. Use instance\_id instead. |
| <a name="output_jump_instance_ids"></a> [jump\_instance\_ids](#output\_jump\_instance\_ids) | [DEPRECATED] Map of instance IDs by instance name. Use instance\_ids instead. |
| <a name="output_jump_instance_private_ip"></a> [jump\_instance\_private\_ip](#output\_jump\_instance\_private\_ip) | [DEPRECATED] Private IP address of the first EC2 instance. Use instance\_private\_ip instead. |
| <a name="output_jump_instance_private_ips"></a> [jump\_instance\_private\_ips](#output\_jump\_instance\_private\_ips) | [DEPRECATED] Map of private IP addresses by instance name. Use instance\_private\_ips instead. |
| <a name="output_jump_instance_public_ip"></a> [jump\_instance\_public\_ip](#output\_jump\_instance\_public\_ip) | [DEPRECATED] Public IP address of the first EC2 instance. Use instance\_public\_ip instead. |
| <a name="output_jump_instance_public_ips"></a> [jump\_instance\_public\_ips](#output\_jump\_instance\_public\_ips) | [DEPRECATED] Map of public IP addresses by instance name. Use instance\_public\_ips instead. |
| <a name="output_jump_instances"></a> [jump\_instances](#output\_jump\_instances) | [DEPRECATED] Map of all EC2 instances. Use instances instead. |
| <a name="output_jump_password_reset"></a> [jump\_password\_reset](#output\_jump\_password\_reset) | How to reset jump server Web UI admin password |
| <a name="output_jump_rdp_port"></a> [jump\_rdp\_port](#output\_jump\_rdp\_port) | Jump server RDP port |
| <a name="output_jump_redis_password"></a> [jump\_redis\_password](#output\_jump\_redis\_password) | Jump server Redis password (sensitive) |
| <a name="output_jump_secret_key"></a> [jump\_secret\_key](#output\_jump\_secret\_key) | Jump server SECRET\_KEY (sensitive, auto-generated on server if not provided) |
| <a name="output_jump_security_group_id"></a> [jump\_security\_group\_id](#output\_jump\_security\_group\_id) | [DEPRECATED] ID of the security group. Use security\_group\_id instead. |
| <a name="output_jump_ssh_port"></a> [jump\_ssh\_port](#output\_jump\_ssh\_port) | Jump server SSH port |
| <a name="output_jumpserver_access_url"></a> [jumpserver\_access\_url](#output\_jumpserver\_access\_url) | [DEPRECATED] Jump server web access URL map. Use jump\_access\_url instead. |
| <a name="output_jumpserver_enabled"></a> [jumpserver\_enabled](#output\_jumpserver\_enabled) | [DEPRECATED] Whether jump server is enabled. Use jump\_enabled instead. |
| <a name="output_key_pair_id"></a> [key\_pair\_id](#output\_key\_pair\_id) | ID of the auto-created EC2 Key Pair (if key\_path file exists and is not empty) |
| <a name="output_key_pair_name"></a> [key\_pair\_name](#output\_key\_pair\_name) | Name of the EC2 Key Pair used (auto-created from key\_path if exists, otherwise from var.key\_name) |
| <a name="output_key_path_status"></a> [key\_path\_status](#output\_key\_path\_status) | Status of key\_path file check (for debugging) |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | ARN of the Launch Template (if ASG enabled) |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | ID of the Launch Template (if ASG enabled) |
| <a name="output_netbird_enabled"></a> [netbird\_enabled](#output\_netbird\_enabled) | Whether NetBird is enabled on the EC2 instance |
| <a name="output_netbird_setup_key"></a> [netbird\_setup\_key](#output\_netbird\_setup\_key) | NetBird setup key for connecting to the NetBird network (sensitive) |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group (always created) |
| <a name="output_security_group_arn_from_vpc"></a> [security\_group\_arn\_from\_vpc](#output\_security\_group\_arn\_from\_vpc) | ARN of the security group from VPC module (if using VPC security group) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group (always created) |
| <a name="output_security_group_id_from_vpc"></a> [security\_group\_id\_from\_vpc](#output\_security\_group\_id\_from\_vpc) | ID of the security group from VPC module (if using VPC security group) |
| <a name="output_ssh_config_file_content"></a> [ssh\_config\_file\_content](#output\_ssh\_config\_file\_content) | Content of the generated SSH config file |
| <a name="output_ssh_config_file_path"></a> [ssh\_config\_file\_path](#output\_ssh\_config\_file\_path) | Path to the generated SSH config file |
| <a name="output_ssm_session_commands"></a> [ssm\_session\_commands](#output\_ssm\_session\_commands) | SSM Session Manager commands to connect to instances (if enabled) |
| <a name="output_ssm_session_manager_enabled"></a> [ssm\_session\_manager\_enabled](#output\_ssm\_session\_manager\_enabled) | Whether SSM Session Manager is enabled for instances |
| <a name="output_zzz_reminder_access_commands"></a> [zzz\_reminder\_access\_commands](#output\_zzz\_reminder\_access\_commands) | ⚠️ REMINDER: Access commands and important information after EC2 deployment |
| <a name="output_zzz_reminders"></a> [zzz\_reminders](#output\_zzz\_reminders) | 📝 REMINDER: Useful commands and next steps after EC2 deployment |
| <a name="output_zzz_sensitive_access_info"></a> [zzz\_sensitive\_access\_info](#output\_zzz\_sensitive\_access\_info) | 🔐 SENSITIVE: Access information for sensitive data (passwords, tokens, keys, etc.) |
| <a name="output_zzz_sensitive_reminder"></a> [zzz\_sensitive\_reminder](#output\_zzz\_sensitive\_reminder) | ⚠️  REMINDER: How to access sensitive information (passwords, tokens, etc.) |
<!-- END_TF_DOCS -->
