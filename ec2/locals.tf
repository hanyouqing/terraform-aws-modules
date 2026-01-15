locals {
  # Generate module name: project-name_prefix-environment
  # If name_prefix is null, empty, or default "ec2", use simplified format: project-environment
  # Otherwise use: project-name_prefix-environment
  name = var.name_prefix != null && var.name_prefix != "" && var.name_prefix != "ec2" ? "${var.project}-${var.name_prefix}-${var.environment}" : "${var.project}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Code        = var.code
      Owner       = var.owner
    },
    var.cost_center != null ? { CostCenter = var.cost_center } : {},
    var.tags
  )

  local_ssh_key_expanded_path = var.key_path != null ? pathexpand(var.key_path) : null
  local_ssh_key_file_exists   = var.key_path != null && local.local_ssh_key_expanded_path != null ? try(fileexists(local.local_ssh_key_expanded_path), false) : false
  local_ssh_key_file_content  = var.key_path != null && local.local_ssh_key_expanded_path != null && local.local_ssh_key_file_exists ? try(file(local.local_ssh_key_expanded_path), "") : ""
  local_ssh_key_exists        = var.key_path != null && local.local_ssh_key_file_exists && length(local.local_ssh_key_file_content) > 0

  key_pair_name = local.name

  default_key_name = local.local_ssh_key_exists ? local.key_pair_name : var.key_name

  base_domain = try(data.terraform_remote_state.vpc.outputs.base_domain, null) != null ? data.terraform_remote_state.vpc.outputs.base_domain : var.domain

  hosted_zone_id = try(data.terraform_remote_state.vpc.outputs.hosted_zone_id, null)

  dns_enabled = local.hosted_zone_id != null && local.base_domain != null && var.dns_enabled

  # Get ACM certificate ARN from VPC if available, otherwise use provided certificate ARN
  alb_certificate_arn = var.alb_certificate_arn != null ? var.alb_certificate_arn : (
    var.enable_alb && local.dns_enabled ? try(data.terraform_remote_state.vpc.outputs.acm_certificate_arn, null) : null
  )

  # Auto-enable HTTPS when ALB and DNS are enabled and certificate is available
  alb_protocol_resolved = var.enable_alb && local.dns_enabled && local.alb_certificate_arn != null ? "HTTPS" : var.alb_protocol

  dns_record_format_resolved = var.dns_record_format != null ? var.dns_record_format : "${var.name_prefix}-{index}.{environment}.{domain}"

  instance_dns_names = local.dns_enabled ? {
    for k, v in local.instances_config : k => (
      # When name_prefix is default "ec2", hostname format is "${project}-${environment}-${i}"
      # DNS name should use hostname directly without adding name_prefix again
      var.name_prefix != null && var.name_prefix != "" && var.name_prefix != "ec2" ? (
        # Custom name_prefix: use DNS format with name_prefix
        replace(
          replace(
            replace(
              replace(local.dns_record_format_resolved, "{name_prefix}", var.name_prefix),
              "{index}",
              replace(k, "${var.name_prefix}-${var.environment}-", "")
            ),
            "{environment}",
            var.environment
          ),
          "{domain}",
          local.base_domain
        )
        ) : (
        # Default name_prefix "ec2": hostname is "${project}-${environment}-${i}", use it directly
        # Format: "{hostname}.{environment}.{domain}"
        "${k}.${var.environment}.${local.base_domain}"
      )
    )
  } : {}

  # Project-based DNS name for jump and gitlab (e.g., jump.production.aws.hanyouqing.com)
  project_dns_name = local.dns_enabled && (var.enable_jump || var.gitlab_enabled) ? "${var.project}.${var.environment}.${local.base_domain}" : null

  private_hosted_zone_name = try(data.terraform_remote_state.vpc.outputs.private_hosted_zone_name, null)

  instance_private_dns_names = local.dns_enabled && local.private_hosted_zone_name != null ? {
    for k, v in local.instances_config : k => (
      # Extract index from hostname and build DNS name
      # Hostname format: when name_prefix is default "ec2", it's "${project}-${environment}-${i}"
      # Otherwise it's "${name_prefix}-${environment}-${i}"
      var.name_prefix != null && var.name_prefix != "" && var.name_prefix != "ec2" ? (
        # Custom name_prefix: hostname is "${name_prefix}-${environment}-${i}", use it directly
        "${k}.${replace(local.private_hosted_zone_name, "/\\.$/", "")}"
        ) : (
        # Default name_prefix "ec2": hostname is "${project}-${environment}-${i}", use it directly
        "${k}.${replace(local.private_hosted_zone_name, "/\\.$/", "")}"
      )
    )
  } : {}

  # AMI selection logic
  # Priority: 1) ami_id (explicit), 2) SSM Parameter Store (by os_type/os_version), 3) Custom AMI lookup
  ami_id = var.ami_id != null ? var.ami_id : (
    var.os_type == "ubuntu" ? (
      var.ubuntu_version == "24.04" || var.os_version == "24.04" ? (
        length(data.aws_ssm_parameter.ubuntu_24_04_ami) > 0 ? data.aws_ssm_parameter.ubuntu_24_04_ami[0].value : null
        ) : (
        # For unsupported Ubuntu versions, try custom AMI lookup if available
        length(data.aws_ami.custom) > 0 ? data.aws_ami.custom[0].id : null
      )
      ) : (
      var.os_type == "amazon-linux" && var.os_version == "2023" ? (
        length(data.aws_ssm_parameter.amazon_linux_2023_ami) > 0 ? data.aws_ssm_parameter.amazon_linux_2023_ami[0].value : null
        ) : (
        var.os_type == "rhel" && var.os_version == "9" ? (
          length(data.aws_ssm_parameter.rhel_9_ami) > 0 ? data.aws_ssm_parameter.rhel_9_ami[0].value : null
          ) : (
          var.os_type == "rhel" && var.os_version == "8" ? (
            length(data.aws_ssm_parameter.rhel_8_ami) > 0 ? data.aws_ssm_parameter.rhel_8_ami[0].value : null
            ) : (
            var.os_type == "debian" && var.os_version == "12" ? (
              length(data.aws_ssm_parameter.debian_12_ami) > 0 ? data.aws_ssm_parameter.debian_12_ami[0].value : null
              ) : (
              var.os_type == "debian" && var.os_version == "11" ? (
                length(data.aws_ssm_parameter.debian_11_ami) > 0 ? data.aws_ssm_parameter.debian_11_ami[0].value : null
                ) : (
                # Fallback to custom AMI lookup for unsupported OS types/versions
                length(data.aws_ami.custom) > 0 ? data.aws_ami.custom[0].id : null
              )
            )
          )
        )
      )
    )
  )

  # Subnet selection logic
  default_subnet_type = var.subnet_type
  default_subnet_id = var.subnet_id != null ? var.subnet_id : (
    var.subnet_type == "private" ? data.terraform_remote_state.vpc.outputs.private_subnet_ids[0] : (
      var.subnet_type == "database" ? data.terraform_remote_state.vpc.outputs.database_subnet_ids[0] : data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
    )
  )

  # User data script selection
  userdata_script_path = var.enable_jump ? "files/jumpserver.ubuntu-24.04.sh" : (var.gitlab_enabled ? "files/gitlab.ubuntu-24.04.sh" : (var.netbird_enabled ? "files/netbird.ubuntu-24.04.sh" : var.userdata_script_path))
  jump_server_script   = var.enable_jump ? file("${path.module}/${local.userdata_script_path}") : null
  gitlab_script        = var.gitlab_enabled ? file("${path.module}/${local.userdata_script_path}") : null
  netbird_script       = var.netbird_enabled ? file("${path.module}/${local.userdata_script_path}") : null
  userdata_base = var.user_data != null ? var.user_data : (
    var.userdata_script_path != null ? file("${path.module}/../../${var.userdata_script_path}") : null
  )

  default_instance_type = var.instance_type != null ? var.instance_type : (
    var.enable_jump ? "t3.medium" : (var.gitlab_enabled ? "t3.large" : "t3.micro")
  )

  default_ebs_volume_size = var.ebs_volume_size != null ? var.ebs_volume_size : (
    var.enable_jump ? 60 : (var.gitlab_enabled ? 100 : 8)
  )

  instance_defaults_merged = {
    instance_type                 = try(var.instance_defaults.instance_type, var.instance_type, local.default_instance_type)
    key_name                      = try(var.instance_defaults.key_name, var.key_name, null)
    hostname_prefix               = var.instance_defaults.hostname_prefix != null ? var.instance_defaults.hostname_prefix : (var.name_prefix != null ? var.name_prefix : "ec2")
    subnet_id                     = try(var.instance_defaults.subnet_id, null)
    subnet_type                   = try(var.instance_defaults.subnet_type, var.subnet_type, "public")
    associate_public_ip           = try(var.instance_defaults.associate_public_ip, var.subnet_type == "public", null)
    enable_monitoring             = try(var.instance_defaults.enable_monitoring, var.enable_monitoring, false)
    ebs_volume_size               = try(var.instance_defaults.ebs_volume_size, var.ebs_volume_size, local.default_ebs_volume_size)
    ebs_volume_type               = try(var.instance_defaults.ebs_volume_type, var.ebs_volume_type, "gp3")
    ebs_encrypted                 = try(var.instance_defaults.ebs_encrypted, var.ebs_encrypted, true)
    ebs_kms_key_id                = try(var.instance_defaults.ebs_kms_key_id, var.ebs_kms_key_id, null)
    enable_termination_protection = try(var.instance_defaults.enable_termination_protection, var.enable_termination_protection, false)
    metadata_options              = try(var.instance_defaults.metadata_options, var.metadata_options, {})
    user_data                     = try(var.instance_defaults.user_data, null)
    user_data_replace_on_change   = try(var.instance_defaults.user_data_replace_on_change, true)
    tags                          = try(var.instance_defaults.tags, {})
  }

  # Build hostname map first: map of index to hostname
  # Hostname format: when name_prefix is default "ec2", use project-environment-index
  # Otherwise use name_prefix-environment-index
  # Always include index suffix, even for single instance (e.g., -1)
  hostname_map = var.instance_count > 0 ? {
    for i in range(1, var.instance_count + 1) : i => (
      var.name_prefix != null && var.name_prefix != "" && var.name_prefix != "ec2" ? "${var.name_prefix}-${var.environment}-${i}" : "${var.project}-${var.environment}-${i}"
    )
  } : {}

  instances_from_count = var.instance_count > 0 ? {
    for i, hostname in local.hostname_map : hostname => {
      instance_type                 = local.instance_defaults_merged.instance_type
      key_name                      = local.instance_defaults_merged.key_name != null ? local.instance_defaults_merged.key_name : local.default_key_name
      hostname                      = hostname
      subnet_id                     = local.instance_defaults_merged.subnet_id
      subnet_type                   = local.instance_defaults_merged.subnet_type
      associate_public_ip           = local.instance_defaults_merged.associate_public_ip
      enable_monitoring             = local.instance_defaults_merged.enable_monitoring
      ebs_volume_size               = local.instance_defaults_merged.ebs_volume_size
      ebs_volume_type               = local.instance_defaults_merged.ebs_volume_type
      ebs_encrypted                 = local.instance_defaults_merged.ebs_encrypted
      ebs_kms_key_id                = local.instance_defaults_merged.ebs_kms_key_id
      enable_termination_protection = local.instance_defaults_merged.enable_termination_protection
      metadata_options              = local.instance_defaults_merged.metadata_options
      user_data                     = local.instance_defaults_merged.user_data
      user_data_replace_on_change   = local.instance_defaults_merged.user_data_replace_on_change
      tags                          = local.instance_defaults_merged.tags
    }
  } : {}

  instances_with_overrides = {
    for hostname, instance in local.instances_from_count : hostname => {
      instance_type                 = try(var.instance_overrides[hostname].instance_type, instance.instance_type)
      key_name                      = try(var.instance_overrides[hostname].key_name, instance.key_name)
      hostname                      = instance.hostname
      subnet_id                     = try(var.instance_overrides[hostname].subnet_id, instance.subnet_id)
      subnet_type                   = try(var.instance_overrides[hostname].subnet_type, instance.subnet_type)
      associate_public_ip           = try(var.instance_overrides[hostname].associate_public_ip, instance.associate_public_ip)
      enable_monitoring             = try(var.instance_overrides[hostname].enable_monitoring, instance.enable_monitoring)
      ebs_volume_size               = try(var.instance_overrides[hostname].ebs_volume_size, instance.ebs_volume_size)
      ebs_volume_type               = try(var.instance_overrides[hostname].ebs_volume_type, instance.ebs_volume_type)
      ebs_encrypted                 = try(var.instance_overrides[hostname].ebs_encrypted, instance.ebs_encrypted)
      ebs_kms_key_id                = try(var.instance_overrides[hostname].ebs_kms_key_id, instance.ebs_kms_key_id)
      enable_termination_protection = try(var.instance_overrides[hostname].enable_termination_protection, instance.enable_termination_protection)
      metadata_options              = try(var.instance_overrides[hostname].metadata_options, instance.metadata_options)
      user_data                     = try(var.instance_overrides[hostname].user_data, instance.user_data)
      user_data_replace_on_change   = try(var.instance_overrides[hostname].user_data_replace_on_change, instance.user_data_replace_on_change)
      tags                          = merge(instance.tags, try(var.instance_overrides[hostname].tags, {}))
    }
  }

  instances_from_var = length(var.instances) > 0 ? {
    for k, v in var.instances : (
      v.hostname != null ? v.hostname : "${local.instance_defaults_merged.hostname_prefix}-${var.environment}-${k}"
      ) => {
      instance_type                 = try(v.instance_type, local.instance_defaults_merged.instance_type)
      key_name                      = try(v.key_name, local.instance_defaults_merged.key_name)
      hostname                      = v.hostname != null ? v.hostname : "${local.instance_defaults_merged.hostname_prefix}-${var.environment}-${k}"
      subnet_id                     = try(v.subnet_id, null)
      subnet_type                   = try(v.subnet_type, local.instance_defaults_merged.subnet_type)
      associate_public_ip           = try(v.associate_public_ip, local.instance_defaults_merged.associate_public_ip)
      enable_monitoring             = try(v.enable_monitoring, local.instance_defaults_merged.enable_monitoring)
      ebs_volume_size               = try(v.ebs_volume_size, local.instance_defaults_merged.ebs_volume_size)
      ebs_volume_type               = try(v.ebs_volume_type, local.instance_defaults_merged.ebs_volume_type)
      ebs_encrypted                 = try(v.ebs_encrypted, local.instance_defaults_merged.ebs_encrypted)
      ebs_kms_key_id                = try(v.ebs_kms_key_id, local.instance_defaults_merged.ebs_kms_key_id)
      enable_termination_protection = try(v.enable_termination_protection, local.instance_defaults_merged.enable_termination_protection)
      metadata_options              = try(v.metadata_options, local.instance_defaults_merged.metadata_options)
      user_data                     = try(v.user_data, local.instance_defaults_merged.user_data)
      user_data_replace_on_change   = try(v.user_data_replace_on_change, local.instance_defaults_merged.user_data_replace_on_change)
      tags                          = merge(local.instance_defaults_merged.tags, try(v.tags, {}))
    }
  } : {}

  legacy_hostname = var.hostname != null ? var.hostname : "${local.instance_defaults_merged.hostname_prefix}-${var.environment}"

  instances_from_legacy = var.instance_count == 0 && length(var.instances) == 0 ? {
    (local.legacy_hostname) = {
      instance_type                 = var.instance_type != null ? var.instance_type : local.default_instance_type
      key_name                      = local.default_key_name
      hostname                      = local.legacy_hostname
      subnet_id                     = var.subnet_id
      subnet_type                   = var.subnet_type
      associate_public_ip           = var.subnet_type == "public" ? true : null
      enable_monitoring             = var.enable_monitoring
      ebs_volume_size               = var.ebs_volume_size != null ? var.ebs_volume_size : local.default_ebs_volume_size
      ebs_volume_type               = var.ebs_volume_type
      ebs_encrypted                 = var.ebs_encrypted
      ebs_kms_key_id                = var.ebs_kms_key_id
      enable_termination_protection = var.enable_termination_protection
      metadata_options              = var.metadata_options
      user_data                     = local.userdata_base
      user_data_replace_on_change   = true
      tags                          = {}
    }
  } : {}

  # When ASG is enabled, don't build instances config (instances won't be created)
  instances_config = var.enable_autoscaling ? {} : (
    length(var.instances) > 0 ? local.instances_from_var : (
      var.instance_count > 0 ? local.instances_with_overrides : local.instances_from_legacy
    )
  )

  # Resolve subnet_id from subnet_type if not explicitly provided
  resolved_subnet_ids = {
    for hostname, instance in local.instances_config : hostname => instance.subnet_id != null ? instance.subnet_id : (
      instance.subnet_type == "private" ? data.terraform_remote_state.vpc.outputs.private_subnet_ids[0] : (
        instance.subnet_type == "database" ? data.terraform_remote_state.vpc.outputs.database_subnet_ids[0] : data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
      )
    )
  }

  # Resolve associate_public_ip based on subnet_type if not explicitly provided
  resolved_associate_public_ip = {
    for hostname, instance in local.instances_config : hostname => instance.associate_public_ip != null ? instance.associate_public_ip : (
      instance.subnet_type == "public" ? true : false
    )
  }

  instances = {
    for hostname, instance in local.instances_config : hostname => {
      hostname = instance.hostname
      # Generate name based on instance_count
      # Always append index suffix, even for single instance (e.g., "ec2-basic-development-1")
      # Extract index from hostname by removing the prefix pattern
      name = var.instance_count > 0 ? (
        # Extract index from hostname
        # Hostname format: when name_prefix is default "ec2", it's "${project}-${environment}-${i}"
        # Otherwise it's "${name_prefix}-${environment}-${i}"
        var.name_prefix != null && var.name_prefix != "" && var.name_prefix != "ec2" ? (
          # Custom name_prefix: extract index from "${name_prefix}-${environment}-${i}"
          "${local.name}-${replace(hostname, "${var.name_prefix}-${var.environment}-", "")}"
          ) : (
          # Default name_prefix "ec2": extract index from "${project}-${environment}-${i}"
          "${local.name}-${replace(hostname, "${var.project}-${var.environment}-", "")}"
        )
      ) : instance.hostname
      instance_type                 = instance.instance_type
      key_name                      = instance.key_name
      subnet_id                     = local.resolved_subnet_ids[hostname]
      associate_public_ip           = local.resolved_associate_public_ip[hostname]
      security_group_ids            = local.resolved_security_group_ids[hostname]
      enable_monitoring             = instance.enable_monitoring
      ebs_volume_size               = instance.ebs_volume_size
      ebs_volume_type               = instance.ebs_volume_type
      ebs_encrypted                 = instance.ebs_encrypted
      ebs_kms_key_id                = instance.ebs_kms_key_id
      enable_termination_protection = instance.enable_termination_protection
      metadata_options              = instance.metadata_options
      user_data                     = instance.user_data != null ? instance.user_data : local.userdata_base
      user_data_replace_on_change   = instance.user_data_replace_on_change
      tags                          = merge(local.common_tags, { Application = var.name_prefix }, instance.tags)
      userdata_content = instance.user_data != null ? instance.user_data : (
        var.enable_jump && local.jump_server_script != null ? replace(
          local.jump_server_script,
          "#!/bin/bash",
          join("\n", compact([
            "#!/bin/bash",
            "export HOSTNAME=\"${instance.hostname}\"",
            "export PROJECT=\"${var.project}\"",
            "export APP=\"${var.name_prefix}\"",
            "export ENVIRONMENT=\"${var.environment}\"",
            "export JUMPSERVER_VERSION=\"${var.jump_version}\"",
            var.jump_secret_key != null ? "export JUMPSERVER_SECRET_KEY=\"${var.jump_secret_key}\"" : null,
            var.jump_bootstrap_token != null ? "export JUMPSERVER_BOOTSTRAP_TOKEN=\"${var.jump_bootstrap_token}\"" : null,
            "export JUMPSERVER_DB_HOST=\"${var.jump_db_host}\"",
            "export JUMPSERVER_DB_PORT=\"${var.jump_db_port}\"",
            "export JUMPSERVER_DB_USER=\"${var.jump_db_user}\"",
            var.jump_db_password != null ? "export JUMPSERVER_DB_PASSWORD=\"${var.jump_db_password}\"" : (var.enable_jump && length(random_password.jump_db) > 0 ? "export JUMPSERVER_DB_PASSWORD=\"${random_password.jump_db[0].result}\"" : "export JUMPSERVER_DB_PASSWORD=\"\""),
            "export JUMPSERVER_DB_NAME=\"${var.jump_db_name}\"",
            "export JUMPSERVER_REDIS_HOST=\"${var.jump_redis_host}\"",
            "export JUMPSERVER_REDIS_PORT=\"${var.jump_redis_port}\"",
            var.jump_redis_password != null ? "export JUMPSERVER_REDIS_PASSWORD=\"${var.jump_redis_password}\"" : (var.enable_jump && length(random_password.jump_redis) > 0 ? "export JUMPSERVER_REDIS_PASSWORD=\"${random_password.jump_redis[0].result}\"" : "export JUMPSERVER_REDIS_PASSWORD=\"\""),
            "export JUMPSERVER_HTTP_PORT=\"${var.jump_http_port}\"",
            "export JUMPSERVER_SSH_PORT=\"${var.jump_ssh_port}\"",
            "export JUMPSERVER_RDP_PORT=\"${var.jump_rdp_port}\"",
            "export JUMPSERVER_DOCKER_SUBNET=\"${var.jump_docker_subnet}\"",
            "export JUMPSERVER_LOG_LEVEL=\"${var.jump_log_level}\""
          ]))
          ) : (
          var.gitlab_enabled && local.gitlab_script != null ? replace(
            local.gitlab_script,
            "#!/bin/bash",
            join("\n", compact([
              "#!/bin/bash",
              "export HOSTNAME=\"${instance.hostname}\"",
              "export PROJECT=\"${var.project}\"",
              "export APP=\"${var.name_prefix}\"",
              "export ENVIRONMENT=\"${var.environment}\"",
              "export GITLAB_EXTERNAL_URL=\"${var.gitlab_external_url}\"",
              "export GITLAB_HTTP_PORT=\"${var.gitlab_http_port}\"",
              "export GITLAB_HTTPS_PORT=\"${var.gitlab_https_port}\"",
              "export GITLAB_SSH_PORT=\"${var.gitlab_ssh_port}\""
            ]))
            ) : (
            var.netbird_enabled && local.netbird_script != null ? replace(
              local.netbird_script,
              "#!/bin/bash",
              join("\n", compact([
                "#!/bin/bash",
                "export HOSTNAME=\"${instance.hostname}\"",
                "export PROJECT=\"${var.project}\"",
                "export APP=\"${var.name_prefix}\"",
                "export ENVIRONMENT=\"${var.environment}\"",
                var.netbird_setup_key != null ? "export NETBIRD_SETUP_KEY=\"${var.netbird_setup_key}\"" : null,
                var.netbird_management_url != null ? "export NETBIRD_MANAGEMENT_URL=\"${var.netbird_management_url}\"" : null
              ]))
              ) : (
              local.userdata_base != null ? replace(
                local.userdata_base,
                "#!/bin/bash",
                join("\n", compact([
                  "#!/bin/bash",
                  "export HOSTNAME=\"${instance.hostname}\"",
                  "export PROJECT=\"${var.project}\"",
                  "export APP=\"${var.name_prefix}\"",
                  "export ENVIRONMENT=\"${var.environment}\"",
                  var.enable_ssm_session_manager ? <<-EOT
                
                # Install and start SSM Agent for Session Manager
                if ! command -v amazon-ssm-agent &> /dev/null; then
                  # Install SSM Agent (Ubuntu 24.04 may have it pre-installed, but ensure it's available)
                  snap install amazon-ssm-agent --classic 2>/dev/null || {
                    # Fallback: Install via deb package if snap fails
                    mkdir -p /tmp/ssm
                    cd /tmp/ssm
                    wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb 2>/dev/null || true
                    if [ -f amazon-ssm-agent.deb ]; then
                      dpkg -i amazon-ssm-agent.deb || apt-get install -f -y
                    fi
                    cd -
                    rm -rf /tmp/ssm
                  }
                fi
                
                # Ensure SSM Agent is running
                systemctl enable amazon-ssm-agent || true
                systemctl start amazon-ssm-agent || true
                systemctl status amazon-ssm-agent || true
                EOT
                  : null,
                  var.cloudwatch_logs_enabled ? <<-EOT
              
              # Configure CloudWatch Logs
              if command -v aws &> /dev/null; then
                # Ensure CloudWatch Logs agent is configured
                # Note: CloudWatch Logs agent configuration should be done via user_data or CloudWatch agent
                echo "CloudWatch Logs enabled for ${instance.hostname}"
              fi
              EOT
                  : null,
                  var.cloudwatch_metrics_enabled ? <<-EOT
              
              # Install and configure CloudWatch agent for metrics
              if command -v aws &> /dev/null; then
                # Download CloudWatch agent
                wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb 2>/dev/null || true
                if [ -f /tmp/amazon-cloudwatch-agent.deb ]; then
                  dpkg -i /tmp/amazon-cloudwatch-agent.deb || apt-get install -f -y
                  systemctl enable amazon-cloudwatch-agent || true
                  systemctl start amazon-cloudwatch-agent || true
                fi
              fi
              EOT
                  : null
                ]))
              ) : ""
            )
          )
        )
      )
    }
  }

  ssh_config_file_path = pathexpand("~/.ssh/conf.d/${var.project}-${var.environment}.conf")

  # Security group selection logic - per instance based on subnet_type
  # Resolve security group for each instance based on its subnet_type
  resolved_security_group_ids = {
    for hostname, instance in local.instances_config : hostname => (
      var.security_group_ids != null ? var.security_group_ids : [aws_security_group.main.id]
    )
  }

  # Legacy: Global security group IDs (for backward compatibility)
  security_group_ids_resolved = var.security_group_ids != null ? var.security_group_ids : [aws_security_group.main.id]

  # Instance map for outputs
  instances_output = {
    for k, v in aws_instance.main : k => {
      id                = v.id
      arn               = v.arn
      public_ip         = v.public_ip
      private_ip        = v.private_ip
      public_dns        = v.public_dns
      ipv6_addresses    = var.enable_ipv6 ? v.ipv6_addresses : []
      instance_type     = v.instance_type
      availability_zone = v.availability_zone
    }
  }

}

