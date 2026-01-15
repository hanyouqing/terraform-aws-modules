# ==============================================================================
# Auto Scaling Group (ASG) Support
# ==============================================================================

# Launch Template for ASG
resource "aws_launch_template" "main" {
  count = var.enable_autoscaling ? 1 : 0

  name_prefix   = "${local.name}-"
  image_id      = local.ami_id
  instance_type = local.instance_defaults_merged.instance_type
  key_name      = local.instance_defaults_merged.key_name != null ? local.instance_defaults_merged.key_name : local.default_key_name

  # For ASG, always use the created security group
  vpc_security_group_ids = var.security_group_ids != null ? var.security_group_ids : [aws_security_group.main.id]

  iam_instance_profile {
    name = var.iam_instance_profile_enabled ? (
      var.iam_instance_profile_name != null ? var.iam_instance_profile_name : aws_iam_instance_profile.main[0].name
    ) : null
  }

  monitoring {
    enabled = local.instance_defaults_merged.enable_monitoring
  }

  dynamic "metadata_options" {
    for_each = local.instance_defaults_merged.metadata_options != null ? [local.instance_defaults_merged.metadata_options] : []
    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")
      http_tokens                 = try(metadata_options.value.http_tokens, "required")
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 2)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, "enabled")
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = local.instance_defaults_merged.ebs_volume_size
      volume_type           = local.instance_defaults_merged.ebs_volume_type
      encrypted             = local.instance_defaults_merged.ebs_encrypted
      kms_key_id            = local.instance_defaults_merged.ebs_kms_key_id
      delete_on_termination = true
    }
  }

  user_data = base64encode(
    var.enable_autoscaling ? (
      # When ASG is enabled, generate user_data from base script with environment variables
      local.userdata_base != null ? replace(
        local.userdata_base,
        "#!/bin/bash",
        join("\n", compact([
          "#!/bin/bash",
          "export HOSTNAME=\"${local.name}\"",
          "export PROJECT=\"${var.project}\"",
          "export APP=\"${var.name_prefix}\"",
          "export ENVIRONMENT=\"${var.environment}\"",
          var.enable_jump ? "export JUMPSERVER_VERSION=\"${var.jump_version}\"" : null,
          var.enable_jump && var.jump_secret_key != null ? "export JUMPSERVER_SECRET_KEY=\"${var.jump_secret_key}\"" : null,
          var.enable_jump && var.jump_bootstrap_token != null ? "export JUMPSERVER_BOOTSTRAP_TOKEN=\"${var.jump_bootstrap_token}\"" : null,
          var.enable_jump ? "export JUMPSERVER_DB_HOST=\"${var.jump_db_host}\"" : null,
          var.enable_jump ? "export JUMPSERVER_DB_PORT=\"${var.jump_db_port}\"" : null,
          var.enable_jump ? "export JUMPSERVER_DB_USER=\"${var.jump_db_user}\"" : null,
          var.enable_jump && var.jump_db_password != null ? "export JUMPSERVER_DB_PASSWORD=\"${var.jump_db_password}\"" : null,
          var.enable_jump ? "export JUMPSERVER_DB_NAME=\"${var.jump_db_name}\"" : null,
          var.enable_jump ? "export JUMPSERVER_REDIS_HOST=\"${var.jump_redis_host}\"" : null,
          var.enable_jump ? "export JUMPSERVER_REDIS_PORT=\"${var.jump_redis_port}\"" : null,
          var.enable_jump && var.jump_redis_password != null ? "export JUMPSERVER_REDIS_PASSWORD=\"${var.jump_redis_password}\"" : null,
          var.enable_jump ? "export JUMPSERVER_HTTP_PORT=\"${var.jump_http_port}\"" : null,
          var.enable_jump ? "export JUMPSERVER_SSH_PORT=\"${var.jump_ssh_port}\"" : null,
          var.enable_jump ? "export JUMPSERVER_RDP_PORT=\"${var.jump_rdp_port}\"" : null,
          var.enable_jump ? "export JUMPSERVER_DOCKER_SUBNET=\"${var.jump_docker_subnet}\"" : null,
          var.enable_jump ? "export JUMPSERVER_LOG_LEVEL=\"${var.jump_log_level}\"" : null,
          var.gitlab_enabled ? "export GITLAB_EXTERNAL_URL=\"${var.gitlab_external_url}\"" : null,
          var.gitlab_enabled ? "export GITLAB_HTTP_PORT=\"${var.gitlab_http_port}\"" : null,
          var.gitlab_enabled ? "export GITLAB_HTTPS_PORT=\"${var.gitlab_https_port}\"" : null,
          var.gitlab_enabled ? "export GITLAB_SSH_PORT=\"${var.gitlab_ssh_port}\"" : null,
          var.netbird_enabled && var.netbird_setup_key != null ? "export NETBIRD_SETUP_KEY=\"${var.netbird_setup_key}\"" : null,
          var.netbird_enabled && var.netbird_management_url != null ? "export NETBIRD_MANAGEMENT_URL=\"${var.netbird_management_url}\"" : null,
          var.enable_ssm_session_manager ? <<-EOT
            
            # Install and start SSM Agent for Session Manager
            if ! command -v amazon-ssm-agent &> /dev/null; then
              snap install amazon-ssm-agent --classic 2>/dev/null || {
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
            systemctl enable amazon-ssm-agent || true
            systemctl start amazon-ssm-agent || true
            EOT
          : null,
          var.cloudwatch_logs_enabled ? "# CloudWatch Logs enabled" : null,
          var.cloudwatch_metrics_enabled ? <<-EOT
            
            # Install and configure CloudWatch agent for metrics
            if command -v aws &> /dev/null; then
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
      ) : (
      length(local.instances) > 0 ? values(local.instances)[0].userdata_content : (
        local.userdata_base != null ? local.userdata_base : ""
      )
    )
  )

  dynamic "instance_market_options" {
    for_each = var.spot_instance_enabled ? [1] : []
    content {
      market_type = "spot"

      spot_options {
        max_price                      = var.spot_price != null ? var.spot_price : (var.spot_max_price != null ? var.spot_max_price : null)
        spot_instance_type             = "one-time"
        instance_interruption_behavior = var.spot_interruption_behavior
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_tags,
      var.asg_tags,
      {
        Name = local.name
        Type = var.name_prefix
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      local.common_tags,
      var.asg_tags,
      {
        Name = "${local.name}-volume"
        Type = "ebs-volume"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-launch-template"
      Type = "launch-template"
    }
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  count = var.enable_autoscaling ? 1 : 0

  name = "${local.name}-asg"
  # When ASG is enabled, instances are not created, so we need to get subnets from VPC remote state
  # Use subnet_type to determine which subnets to use
  vpc_zone_identifier = var.subnet_type == "private" ? try(data.terraform_remote_state.vpc.outputs.private_subnet_ids, []) : (
    var.subnet_type == "database" ? try(data.terraform_remote_state.vpc.outputs.database_subnet_ids, []) : try(data.terraform_remote_state.vpc.outputs.public_subnet_ids, [])
  )
  target_group_arns         = var.enable_alb && length(aws_lb_target_group.main) > 0 ? [aws_lb_target_group.main[0].arn] : []
  health_check_type         = var.asg_health_check_type
  health_check_grace_period = var.asg_health_check_grace_period

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  default_cooldown          = var.asg_default_cooldown
  termination_policies      = var.asg_termination_policies
  wait_for_capacity_timeout = "10m"

  launch_template {
    id      = aws_launch_template.main[0].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, var.asg_tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }

  tag {
    key                 = "Type"
    value               = var.name_prefix
    propagate_at_launch = true
  }
}
