variable "environment" {
  description = "Environment name (development, testing, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "testing", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, testing, staging, production"
  }
}

variable "project" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_remote_state_key" {
  description = "Remote state key for VPC module. Must match the key in your VPC module's backend.tf configuration. Example: 'hanyouqing/terraform-aws-modules:vpc/examples/basic/terraform.tfstate'"
  type        = string
  default     = "vpc/terraform.tfstate"
}

variable "vpc_remote_state_bucket" {
  description = "S3 bucket name for VPC remote state"
  type        = string
}

variable "vpc_remote_state_workspace_key_prefix" {
  description = "Workspace key prefix for VPC remote state. Must match the workspace_key_prefix in your VPC module's backend.tf configuration. Example: 'env:development' or 'env:'"
  type        = string
  default     = "env:"
}

variable "code" {
  description = "Code repository and path (e.g., 'reponame:path/to/terraform/ec2')"
  type        = string
  default     = ""
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "assume_role_arn" {
  description = "IAM role ARN to assume for cross-account access (optional)"
  type        = string
  default     = null
}

variable "assume_role_external_id" {
  description = "External ID to use when assuming role (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "assume_role_session_name" {
  description = "Session name to use when assuming role"
  type        = string
  default     = "terraform-ec2"
}

variable "instance_type" {
  description = "EC2 instance type. Defaults to t3.micro for general use, t3.medium when jump server is enabled, t3.large when GitLab is enabled"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the AWS EC2 Key Pair to use for SSH access (optional: if key_path is provided and file exists, it will be automatically uploaded and used as default)"
  type        = string
  default     = null
}

variable "key_path" {
  description = "Path to SSH public key file (e.g., ~/.ssh/ec2-production.pub). If provided and file exists with non-empty content, will automatically create EC2 Key Pair. Recommended format: ~/.ssh/{name_prefix}-{environment}.pub where {environment} matches the environment variable value"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID to use for instances. If not specified, will use Ubuntu 24.04 LTS from SSM Parameter Store"
  type        = string
  default     = null
}

variable "ami_owner" {
  description = "AMI owner for AMI lookup (e.g., '099720109477' for Canonical/Ubuntu, 'amazon' for Amazon Linux)"
  type        = string
  default     = "099720109477"
}

variable "ami_name_filter" {
  description = "AMI name filter for AMI lookup. Used when ami_id is not specified"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"
}

variable "os_type" {
  description = "Operating system type. Options: ubuntu, amazon-linux, rhel, debian"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "amazon-linux", "rhel", "debian"], var.os_type)
    error_message = "os_type must be one of: ubuntu, amazon-linux, rhel, debian"
  }
}

variable "os_version" {
  description = "Operating system version. For Ubuntu: 24.04. For Amazon Linux: 2023. For RHEL: 8 or 9. For Debian: 12 or 11"
  type        = string
  default     = "24.04"
}

variable "ubuntu_version" {
  description = "Ubuntu version to use when using SSM Parameter Store (24.04). Only used when ami_id is null and os_type is ubuntu. Deprecated: use os_type and os_version instead"
  type        = string
  default     = "24.04"

  validation {
    condition     = contains(["24.04"], var.ubuntu_version)
    error_message = "Ubuntu version must be 24.04 (22.04 is EOL and no longer supported)"
  }
}

variable "userdata_script_path" {
  description = "Path to the userdata script file (relative to module root or absolute path). Used when enable_jump is false. Use minimal version for EC2 to avoid 16KB limit."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script content. If provided, overrides userdata_script_path. Can be used for custom initialization scripts"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring (costs extra, basic monitoring is free)"
  type        = bool
  default     = false
}

variable "ebs_volume_size" {
  description = "Size of the EBS root volume in GB. Minimum 60GB recommended when jump server is enabled, 100GB when GitLab is enabled"
  type        = number
  default     = null

  validation {
    condition     = var.ebs_volume_size == null || var.ebs_volume_size >= 8
    error_message = "EBS volume size must be at least 8 GB"
  }
}

variable "ebs_volume_type" {
  description = "Type of EBS volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "gp2", "io1", "io2"], var.ebs_volume_type)
    error_message = "EBS volume type must be one of: gp3, gp2, io1, io2"
  }
}

variable "ebs_encrypted" {
  description = "Enable encryption for EBS volume"
  type        = bool
  default     = true
}

variable "ebs_kms_key_id" {
  description = "KMS key ID for EBS encryption (optional, uses default if not specified)"
  type        = string
  default     = null
}

variable "enable_termination_protection" {
  description = "Enable termination protection for the instance"
  type        = bool
  default     = false
}

variable "metadata_options" {
  description = "Instance metadata options"
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 2)
    instance_metadata_tags      = optional(string, "enabled")
  })
  default = {}
}

variable "subnet_id" {
  description = "Subnet ID for instances (if not specified, uses first public subnet from VPC). Use subnet_type or subnet_ids in instance configuration instead"
  type        = string
  default     = null
}

variable "subnet_type" {
  description = "Subnet type to use when subnet_id is not specified (public, private, database). Defaults to public"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "database"], var.subnet_type)
    error_message = "subnet_type must be one of: public, private, database"
  }
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to instances. If not specified, uses VPC security group or creates new security group based on security_group_rules"
  type        = list(string)
  default     = null
}

variable "security_group_rules" {
  description = "Map of security group rules to create a new security group. Format: { rule_name => { type = \"ingress\"|\"egress\", from_port = 22, to_port = 22, protocol = \"tcp\", cidr_blocks = [\"0.0.0.0/0\"] } }"
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    prefix_list_ids          = optional(list(string), [])
    source_security_group_id = optional(string, null)
    description              = optional(string, "")
  }))
  default = {}
}


variable "hostname" {
  description = "Hostname prefix for instances (optional, use instances variable or instance_defaults.hostname_prefix instead)"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Prefix for resource names (e.g., 'web', 'app', 'ec2'). Defaults to 'ec2'"
  type        = string
  default     = "ec2"
}

variable "enable_eip" {
  description = "Enable Elastic IP allocation for instances in public subnets. When enabled, each instance in a public subnet (associate_public_ip = true) will get a static public IP address. Useful for jump servers and other services that need a stable public IP. Note: Instances must be in public subnets for EIP to work."
  type        = bool
  default     = false
}

variable "enable_ssm_session_manager" {
  description = "Enable AWS Systems Manager Session Manager for secure, SSH-free access to instances. When enabled, automatically attaches AmazonSSMManagedInstanceCore policy and ensures SSM Agent is running. This provides a more secure alternative to SSH."
  type        = bool
  default     = false
}

variable "spot_instance_enabled" {
  description = "Enable Spot instance for cost optimization. Spot instances can be interrupted with 2-minute notice. Not recommended for production workloads."
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "Maximum price per hour for Spot instance (optional). If not specified, uses current Spot price."
  type        = string
  default     = null
}

variable "spot_instance_type" {
  description = "Instance type for Spot instance (optional). If not specified, uses the same instance_type as on-demand instances."
  type        = string
  default     = null
}

variable "spot_interruption_behavior" {
  description = "Behavior when Spot instance is interrupted. Options: stop, terminate, hibernate"
  type        = string
  default     = "terminate"

  validation {
    condition     = contains(["stop", "terminate", "hibernate"], var.spot_interruption_behavior)
    error_message = "spot_interruption_behavior must be one of: stop, terminate, hibernate"
  }
}

variable "spot_max_price" {
  description = "Maximum price per hour for Spot instance. If not specified, uses current Spot price. This is an alias for spot_price for clarity."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Number of EC2 instances to create. If set, instances will be generated automatically using instance_defaults. The instances map will use hostname as the key (e.g., 'ec2-production-1', 'ec2-production-2'). Recommended approach for multiple instances."
  type        = number
  default     = 0

  validation {
    condition     = var.instance_count >= 0
    error_message = "Instance count must be greater than or equal to 0"
  }
}

variable "instance_defaults" {
  description = "Default configuration for instances when using instance_count. Individual instances can override these defaults via instance_overrides."
  type = object({
    instance_type                 = optional(string, null)
    key_name                      = optional(string, null)
    hostname_prefix               = optional(string, null)
    subnet_id                     = optional(string, null)
    subnet_type                   = optional(string, null)
    associate_public_ip           = optional(bool, null)
    enable_monitoring             = optional(bool, false)
    ebs_volume_size               = optional(number, null)
    ebs_volume_type               = optional(string, "gp3")
    ebs_encrypted                 = optional(bool, true)
    ebs_kms_key_id                = optional(string, null)
    enable_termination_protection = optional(bool, false)
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 2)
      instance_metadata_tags      = optional(string, "enabled")
    }), {})
    user_data                   = optional(string, null)
    user_data_replace_on_change = optional(bool, true)
    tags                        = optional(map(string), {})
  })
  default = {}
}

variable "instance_overrides" {
  description = "Map of instance-specific overrides. Key is hostname, value is instance configuration object that will override instance_defaults."
  type = map(object({
    instance_type                 = optional(string, null)
    key_name                      = optional(string, null)
    subnet_id                     = optional(string, null)
    subnet_type                   = optional(string, null)
    associate_public_ip           = optional(bool, null)
    enable_monitoring             = optional(bool, null)
    ebs_volume_size               = optional(number, null)
    ebs_volume_type               = optional(string, null)
    ebs_encrypted                 = optional(bool, null)
    ebs_kms_key_id                = optional(string, null)
    enable_termination_protection = optional(bool, null)
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 2)
      instance_metadata_tags      = optional(string, "enabled")
    }), null)
    user_data                   = optional(string, null)
    user_data_replace_on_change = optional(bool, null)
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "instances" {
  description = "Map of instance configurations. Key is instance name, value is instance configuration object. Use instance_count and instance_defaults instead."
  type = map(object({
    instance_type                 = optional(string, null)
    key_name                      = optional(string, null)
    hostname                      = optional(string, null)
    subnet_id                     = optional(string, null)
    subnet_type                   = optional(string, null)
    associate_public_ip           = optional(bool, null)
    enable_monitoring             = optional(bool, false)
    ebs_volume_size               = optional(number, null)
    ebs_volume_type               = optional(string, "gp3")
    ebs_encrypted                 = optional(bool, true)
    ebs_kms_key_id                = optional(string, null)
    enable_termination_protection = optional(bool, false)
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 2)
      instance_metadata_tags      = optional(string, "enabled")
    }), {})
    user_data                   = optional(string, null)
    user_data_replace_on_change = optional(bool, true)
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "cost_center" {
  description = "Cost center for cost allocation"
  type        = string
  default     = null
}

variable "enable_jump" {
  description = "Enable jump server deployment on instances. When enabled, automatically deploys jump server via userdata and configures security group rules"
  type        = bool
  default     = false
}

variable "jump_version" {
  description = "Jump server version to install (e.g., v2.28.8)"
  type        = string
  default     = "v2.28.8"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+", var.jump_version))
    error_message = "Jump server version must be in format vX.Y.Z (e.g., v2.28.8)"
  }
}

variable "jump_secret_key" {
  description = "Jump server SECRET_KEY (50+ characters). If not provided, will be auto-generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "jump_bootstrap_token" {
  description = "Jump server BOOTSTRAP_TOKEN (24+ characters). If not provided, will be auto-generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "jump_db_host" {
  description = "Jump server database host (use 'localhost' for local MySQL, or RDS endpoint for external database)"
  type        = string
  default     = "localhost"
}

variable "jump_db_port" {
  description = "Jump server database port"
  type        = number
  default     = 3306

  validation {
    condition     = var.jump_db_port > 0 && var.jump_db_port <= 65535
    error_message = "Database port must be between 1 and 65535"
  }
}

variable "jump_db_user" {
  description = "Jump server database user"
  type        = string
  default     = "root"
}

variable "jump_db_password" {
  description = "Jump server database password. If not provided and enable_jump is true, a random password will be auto-generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "jump_db_name" {
  description = "Jump server database name"
  type        = string
  default     = "jumpserver"
}

variable "jump_redis_host" {
  description = "Jump server Redis host (use 'localhost' for local Redis, or ElastiCache endpoint for external Redis)"
  type        = string
  default     = "localhost"
}

variable "jump_redis_port" {
  description = "Jump server Redis port"
  type        = number
  default     = 6379

  validation {
    condition     = var.jump_redis_port > 0 && var.jump_redis_port <= 65535
    error_message = "Redis port must be between 1 and 65535"
  }
}

variable "jump_redis_password" {
  description = "Jump server Redis password. If not provided and enable_jump is true, a random password will be auto-generated. Set to empty string to disable password."
  type        = string
  default     = null
  sensitive   = true
}

variable "jump_http_port" {
  description = "Jump server HTTP port"
  type        = number
  default     = 80

  validation {
    condition     = var.jump_http_port > 0 && var.jump_http_port <= 65535
    error_message = "HTTP port must be between 1 and 65535"
  }
}

variable "jump_ssh_port" {
  description = "Jump server SSH port"
  type        = number
  default     = 22

  validation {
    condition     = var.jump_ssh_port > 0 && var.jump_ssh_port <= 65535
    error_message = "SSH port must be between 1 and 65535"
  }
}

variable "jump_rdp_port" {
  description = "Jump server RDP port"
  type        = number
  default     = 3389

  validation {
    condition     = var.jump_rdp_port > 0 && var.jump_rdp_port <= 65535
    error_message = "RDP port must be between 1 and 65535"
  }
}

variable "jump_docker_subnet" {
  description = "Jump server Docker subnet CIDR"
  type        = string
  default     = "192.168.250.0/24"

  validation {
    condition     = can(cidrhost(var.jump_docker_subnet, 0))
    error_message = "Docker subnet must be a valid CIDR block"
  }
}

variable "jump_log_level" {
  description = "Jump server log level (ERROR, WARNING, INFO, DEBUG)"
  type        = string
  default     = "ERROR"

  validation {
    condition     = contains(["ERROR", "WARNING", "INFO", "DEBUG"], var.jump_log_level)
    error_message = "Log level must be one of: ERROR, WARNING, INFO, DEBUG"
  }
}

variable "gitlab_enabled" {
  description = "Enable GitLab CE installation on instances. When enabled, automatically deploys GitLab via userdata and configures security group rules"
  type        = bool
  default     = false
}

variable "gitlab_external_url" {
  description = "GitLab external URL (e.g., http://gitlab.example.com or https://gitlab.example.com). Used for GitLab configuration"
  type        = string
  default     = "http://gitlab.example.com"
}

variable "gitlab_http_port" {
  description = "GitLab HTTP port"
  type        = number
  default     = 80

  validation {
    condition     = var.gitlab_http_port > 0 && var.gitlab_http_port <= 65535
    error_message = "HTTP port must be between 1 and 65535"
  }
}

variable "gitlab_https_port" {
  description = "GitLab HTTPS port"
  type        = number
  default     = 443

  validation {
    condition     = var.gitlab_https_port > 0 && var.gitlab_https_port <= 65535
    error_message = "HTTPS port must be between 1 and 65535"
  }
}

variable "gitlab_ssh_port" {
  description = "GitLab SSH port (for Git operations)"
  type        = number
  default     = 22

  validation {
    condition     = var.gitlab_ssh_port > 0 && var.gitlab_ssh_port <= 65535
    error_message = "SSH port must be between 1 and 65535"
  }
}

variable "netbird_enabled" {
  description = "Enable NetBird VPN client installation on instances. When enabled, automatically installs NetBird and connects to the NetBird network using the setup key"
  type        = bool
  default     = false
}

variable "netbird_setup_key" {
  description = "NetBird setup key for connecting to the NetBird network. Required when netbird_enabled is true. Get this from your NetBird Management Dashboard"
  type        = string
  default     = null
  sensitive   = true
}

variable "netbird_management_url" {
  description = "NetBird management URL (optional). If not specified, uses the default NetBird cloud management. Use this if you have a self-hosted NetBird management server"
  type        = string
  default     = null
}

variable "enable_alb" {
  description = "Enable Application Load Balancer for EC2 instances"
  type        = bool
  default     = false
}

variable "alb_internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "alb_subnet_type" {
  description = "Subnet type for ALB (public, private, database). Defaults to public for internet-facing, private for internal"
  type        = string
  default     = null

  validation {
    condition     = var.alb_subnet_type == null || contains(["public", "private", "database"], var.alb_subnet_type)
    error_message = "alb_subnet_type must be one of: public, private, database"
  }
}

variable "alb_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80

  validation {
    condition     = var.alb_port > 0 && var.alb_port <= 65535
    error_message = "ALB port must be between 1 and 65535"
  }
}

variable "alb_protocol" {
  description = "Protocol for ALB listener (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.alb_protocol)
    error_message = "ALB protocol must be HTTP or HTTPS"
  }
}

variable "alb_target_port" {
  description = "Target port on EC2 instances for ALB"
  type        = number
  default     = 80

  validation {
    condition     = var.alb_target_port > 0 && var.alb_target_port <= 65535
    error_message = "ALB target port must be between 1 and 65535"
  }
}

variable "alb_target_protocol" {
  description = "Target protocol for ALB (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.alb_target_protocol)
    error_message = "ALB target protocol must be HTTP or HTTPS"
  }
}

variable "alb_health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/"
}

variable "alb_health_check_port" {
  description = "Health check port for ALB target group"
  type        = number
  default     = null

  validation {
    condition     = var.alb_health_check_port == null || (var.alb_health_check_port > 0 && var.alb_health_check_port <= 65535)
    error_message = "ALB health check port must be between 1 and 65535"
  }
}

variable "alb_health_check_protocol" {
  description = "Health check protocol for ALB target group (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.alb_health_check_protocol)
    error_message = "ALB health check protocol must be HTTP or HTTPS"
  }
}

variable "alb_health_check_interval" {
  description = "Health check interval in seconds for ALB"
  type        = number
  default     = 30

  validation {
    condition     = var.alb_health_check_interval >= 5 && var.alb_health_check_interval <= 300
    error_message = "ALB health check interval must be between 5 and 300 seconds"
  }
}

variable "alb_health_check_timeout" {
  description = "Health check timeout in seconds for ALB"
  type        = number
  default     = 5

  validation {
    condition     = var.alb_health_check_timeout >= 2 && var.alb_health_check_timeout <= 120
    error_message = "ALB health check timeout must be between 2 and 120 seconds"
  }
}

variable "alb_health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks before marking target as healthy"
  type        = number
  default     = 2

  validation {
    condition     = var.alb_health_check_healthy_threshold >= 2 && var.alb_health_check_healthy_threshold <= 10
    error_message = "ALB healthy threshold must be between 2 and 10"
  }
}

variable "alb_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking target as unhealthy"
  type        = number
  default     = 2

  validation {
    condition     = var.alb_health_check_unhealthy_threshold >= 2 && var.alb_health_check_unhealthy_threshold <= 10
    error_message = "ALB unhealthy threshold must be between 2 and 10"
  }
}

variable "alb_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener (required if alb_protocol is HTTPS)"
  type        = string
  default     = null
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "enable_elb" {
  description = "Enable Classic Load Balancer (ELB) for EC2 instances"
  type        = bool
  default     = false
}

variable "elb_internal" {
  description = "Whether the ELB is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "elb_subnet_type" {
  description = "Subnet type for ELB (public, private, database). Defaults to public for internet-facing, private for internal"
  type        = string
  default     = null

  validation {
    condition     = var.elb_subnet_type == null || contains(["public", "private", "database"], var.elb_subnet_type)
    error_message = "elb_subnet_type must be one of: public, private, database"
  }
}

variable "elb_listener_port" {
  description = "Port for ELB listener"
  type        = number
  default     = 80

  validation {
    condition     = var.elb_listener_port > 0 && var.elb_listener_port <= 65535
    error_message = "ELB listener port must be between 1 and 65535"
  }
}

variable "elb_listener_protocol" {
  description = "Protocol for ELB listener (HTTP, HTTPS, TCP, SSL)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "SSL"], var.elb_listener_protocol)
    error_message = "ELB listener protocol must be HTTP, HTTPS, TCP, or SSL"
  }
}

variable "elb_instance_port" {
  description = "Port on EC2 instances for ELB"
  type        = number
  default     = 80

  validation {
    condition     = var.elb_instance_port > 0 && var.elb_instance_port <= 65535
    error_message = "ELB instance port must be between 1 and 65535"
  }
}

variable "elb_instance_protocol" {
  description = "Protocol for ELB instance connection (HTTP, HTTPS, TCP, SSL)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "SSL"], var.elb_instance_protocol)
    error_message = "ELB instance protocol must be HTTP, HTTPS, TCP, or SSL"
  }
}

variable "elb_health_check_target" {
  description = "Health check target for ELB (e.g., HTTP:80/health or TCP:80)"
  type        = string
  default     = "HTTP:80/"
}

variable "elb_health_check_interval" {
  description = "Health check interval in seconds for ELB"
  type        = number
  default     = 30

  validation {
    condition     = var.elb_health_check_interval >= 5 && var.elb_health_check_interval <= 300
    error_message = "ELB health check interval must be between 5 and 300 seconds"
  }
}

variable "elb_health_check_timeout" {
  description = "Health check timeout in seconds for ELB"
  type        = number
  default     = 5

  validation {
    condition     = var.elb_health_check_timeout >= 2 && var.elb_health_check_timeout <= 60
    error_message = "ELB health check timeout must be between 2 and 60 seconds"
  }
}

variable "elb_health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks before marking instance as healthy"
  type        = number
  default     = 2

  validation {
    condition     = var.elb_health_check_healthy_threshold >= 2 && var.elb_health_check_healthy_threshold <= 10
    error_message = "ELB healthy threshold must be between 2 and 10"
  }
}

variable "elb_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking instance as unhealthy"
  type        = number
  default     = 2

  validation {
    condition     = var.elb_health_check_unhealthy_threshold >= 2 && var.elb_health_check_unhealthy_threshold <= 10
    error_message = "ELB unhealthy threshold must be between 2 and 10"
  }
}

variable "elb_certificate_id" {
  description = "ARN of SSL certificate for HTTPS/SSL listener (required if elb_listener_protocol is HTTPS or SSL)"
  type        = string
  default     = null
}

variable "elb_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing for ELB"
  type        = bool
  default     = true
}

variable "elb_connection_draining" {
  description = "Enable connection draining for ELB"
  type        = bool
  default     = true
}

variable "elb_connection_draining_timeout" {
  description = "Connection draining timeout in seconds for ELB"
  type        = number
  default     = 300

  validation {
    condition     = var.elb_connection_draining_timeout >= 0 && var.elb_connection_draining_timeout <= 3600
    error_message = "ELB connection draining timeout must be between 0 and 3600 seconds"
  }
}

variable "elb_idle_timeout" {
  description = "Idle timeout in seconds for ELB"
  type        = number
  default     = 60

  validation {
    condition     = var.elb_idle_timeout >= 1 && var.elb_idle_timeout <= 4000
    error_message = "ELB idle timeout must be between 1 and 4000 seconds"
  }
}

variable "iam_instance_profile_enabled" {
  description = "Enable IAM instance profile for AWS service access (RDS, ElastiCache, ECR, EKS, ECS, etc.)"
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "Name of existing IAM instance profile to attach. If specified, iam_instance_profile_enabled must be true and custom IAM role/policies will not be created"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name for the IAM role (when creating new role). Defaults to {name_prefix}-{environment}-role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Map of additional IAM policies to attach to the IAM role. Format: { policy_name => policy_json }"
  type        = map(string)
  default     = {}
}

variable "iam_role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "ec2_external_policy_arns" {
  description = "List of external IAM policy ARNs to attach to the IAM role. This is an alias for iam_role_policy_arns for clarity when attaching external policies."
  type        = list(string)
  default     = []
}

variable "enable_rds" {
  description = "Enable RDS access permissions (Secrets Manager and RDS describe). When enabled, allows EC2 instance to access RDS secrets and describe RDS instances."
  type        = bool
  default     = false
}

variable "enable_ecr" {
  description = "Enable ECR access permissions. When enabled, allows EC2 instance to pull/push Docker images from/to ECR repositories."
  type        = bool
  default     = false
}

variable "enable_eks" {
  description = "Enable EKS access permissions. When enabled, allows EC2 instance to describe EKS clusters and configure kubectl access."
  type        = bool
  default     = false
}

variable "enable_elasticache" {
  description = "Enable ElastiCache access permissions. When enabled, allows EC2 instance to describe ElastiCache clusters and nodes."
  type        = bool
  default     = false
}

variable "enable_ecs" {
  description = "Enable ECS access permissions. When enabled, allows EC2 instance to describe ECS clusters, services, tasks, and execute commands in containers."
  type        = bool
  default     = false
}

variable "dns_enabled" {
  description = "Enable Route53 DNS records for instances"
  type        = bool
  default     = false
}

variable "dns_record_format" {
  description = "Format for DNS record names. Variables: {name_prefix}, {index}, {environment}, {domain}. Default: '{name_prefix}-{index}.{environment}.{domain}'"
  type        = string
  default     = null
}

variable "dns_ttl" {
  description = "TTL for Route53 DNS records in seconds. Lower TTL (60-120 seconds) ensures faster DNS updates when instance IP changes."
  type        = number
  default     = 60

  validation {
    condition     = var.dns_ttl >= 60 && var.dns_ttl <= 86400
    error_message = "DNS TTL must be between 60 and 86400 seconds"
  }
}

variable "cloudwatch_logs_enabled" {
  description = "Enable CloudWatch Logs for instances. When enabled, creates log groups and configures log streaming."
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_days" {
  description = "Number of days to retain CloudWatch logs. Options: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, or 0 (never expire)"
  type        = number
  default     = 7

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_days)
    error_message = "cloudwatch_logs_retention_days must be one of: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
  }
}

variable "cloudwatch_logs_group_name" {
  description = "Name of the CloudWatch Logs group. If not specified, uses {name_prefix}-{environment}-logs"
  type        = string
  default     = null
}

variable "cloudwatch_metrics_enabled" {
  description = "Enable custom CloudWatch metrics collection. When enabled, installs CloudWatch agent and configures metrics."
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "Enable Auto Scaling Group for instances. When enabled, creates a Launch Template and ASG instead of individual EC2 instances. Note: When ASG is enabled, instance_count and instances variables are ignored."
  type        = bool
  default     = false
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1

  validation {
    condition     = var.asg_min_size >= 0
    error_message = "asg_min_size must be greater than or equal to 0"
  }
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3

  validation {
    condition     = var.asg_max_size > 0
    error_message = "asg_max_size must be greater than 0"
  }
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1

  validation {
    condition     = var.asg_desired_capacity >= 0
    error_message = "asg_desired_capacity must be greater than or equal to 0"
  }
}

variable "asg_health_check_type" {
  description = "Health check type for ASG. Options: EC2, ELB"
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.asg_health_check_type)
    error_message = "asg_health_check_type must be one of: EC2, ELB"
  }
}

variable "asg_health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "asg_default_cooldown" {
  description = "Default cooldown period in seconds"
  type        = number
  default     = 300
}

variable "asg_termination_policies" {
  description = "List of termination policies for ASG"
  type        = list(string)
  default     = ["Default"]
}

variable "asg_tags" {
  description = "Additional tags for ASG instances"
  type        = map(string)
  default     = {}
}

variable "enable_ipv6" {
  description = "Enable IPv6 support for EC2 instances. Requires subnet to have IPv6 CIDR block assigned."
  type        = bool
  default     = false
}

variable "domain" {
  description = "Base domain for DNS records (e.g., example.com). If VPC remote state has a domain configured, it will be used; otherwise this default will be used."
  type        = string
  default     = null
}

variable "ipv6_address_count" {
  description = "Number of IPv6 addresses to assign to each instance. Requires enable_ipv6 = true"
  type        = number
  default     = 1

  validation {
    condition     = var.ipv6_address_count >= 0 && var.ipv6_address_count <= 10
    error_message = "ipv6_address_count must be between 0 and 10"
  }
}

variable "additional_ebs_volumes" {
  description = "Map of additional EBS volumes to attach to instances. Key format: '{instance_name}.{volume_name}'. Example: { 'web-1.data' => { size = 100, type = 'gp3' } }"
  type = map(object({
    size        = number
    type        = optional(string, "gp3")
    encrypted   = optional(bool, true)
    kms_key_id  = optional(string, null)
    device_name = optional(string, null)
    tags        = optional(map(string), {})
  }))
  default = {}
}

