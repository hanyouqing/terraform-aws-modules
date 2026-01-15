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
- Uses community-maintained Terraform module for EC2 instances

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
