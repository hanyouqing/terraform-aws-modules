output "ec2_name" {
  description = "Name of the EC2 module (for reference)"
  value       = local.name
}

output "instances" {
  description = "Map of all EC2 instances (empty if ASG is enabled)"
  value = var.enable_autoscaling ? {} : {
    for k, v in local.instances_output : k => {
      id         = v.id
      arn        = v.arn
      public_ip  = v.public_ip
      private_ip = v.private_ip
      public_dns = v.public_dns
      name       = local.instances[k].name
    }
  }
}

output "instance_ids" {
  description = "Map of instance IDs by instance name"
  value = {
    for k, v in local.instances_output : k => v.id
  }
}

output "instance_public_ips" {
  description = "Map of public IP addresses by instance name (Elastic IP if enable_eip is true, otherwise auto-assigned public IP)"
  value = {
    for k, v in local.instances_output : k => v.public_ip
  }
}

output "instance_private_ips" {
  description = "Map of private IP addresses by instance name"
  value = {
    for k, v in local.instances_output : k => v.private_ip
  }
}

output "instance_ipv6_addresses_map" {
  description = "Map of IPv6 addresses by instance name (if IPv6 enabled)"
  value = var.enable_ipv6 ? {
    for k, v in local.instances_output : k => v.ipv6_addresses
  } : {}
}

output "instance_id" {
  description = "ID of the first EC2 instance"
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].id : null
}

output "instance_arn" {
  description = "ARN of the first EC2 instance"
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].arn : null
}

output "instance_public_ip" {
  description = "Public IP address of the first EC2 instance (Elastic IP if enable_eip is true, otherwise auto-assigned public IP)"
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].public_ip : null
}

output "instance_elastic_ip" {
  description = "Elastic IP address of the first EC2 instance (if enable_eip is true)"
  value       = var.enable_eip && length(local.instances_output) > 0 ? try(aws_eip.main[keys(local.instances_output)[0]].public_ip, null) : null
}

output "elastic_ips" {
  description = "Map of Elastic IP addresses by instance hostname (if enable_eip is true)"
  value = var.enable_eip ? {
    for hostname, eip in aws_eip.main : hostname => eip.public_ip
  } : {}
}

output "elastic_ip_ids" {
  description = "Map of Elastic IP allocation IDs by instance hostname (if enable_eip is true)"
  value = var.enable_eip ? {
    for hostname, eip in aws_eip.main : hostname => eip.id
  } : {}
}

output "instance_private_ip" {
  description = "Private IP address of the first EC2 instance"
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].private_ip : null
}

output "instance_ipv6_addresses" {
  description = "IPv6 addresses of the first EC2 instance (if IPv6 enabled)"
  value       = var.enable_ipv6 && length(local.instances_output) > 0 ? values(local.instances_output)[0].ipv6_addresses : []
}

output "instance_dns" {
  description = "Public DNS name of the first EC2 instance"
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].public_dns : null
}

output "security_group_id_from_vpc" {
  description = "ID of the security group from VPC module (if using VPC security group)"
  value       = try(data.terraform_remote_state.vpc.outputs.jump_security_group_id, null)
}

output "security_group_arn_from_vpc" {
  description = "ARN of the security group from VPC module (if using VPC security group)"
  value       = try(data.terraform_remote_state.vpc.outputs.jump_security_group_arn, null)
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to instances"
  value       = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && length(aws_iam_role.main) > 0 ? aws_iam_role.main[0].arn : null
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to instances"
  value       = var.iam_instance_profile_enabled ? (var.iam_instance_profile_name != null ? var.iam_instance_profile_name : (length(aws_iam_instance_profile.main) > 0 ? aws_iam_instance_profile.main[0].name : null)) : null
}

output "security_group_id" {
  description = "ID of the security group (always created)"
  value       = aws_security_group.main.id
}

output "security_group_arn" {
  description = "ARN of the security group (always created)"
  value       = aws_security_group.main.arn
}

output "key_pair_name" {
  description = "Name of the EC2 Key Pair used (auto-created from key_path if exists, otherwise from var.key_name)"
  value       = local.default_key_name
}

output "key_path_status" {
  description = "Status of key_path file check (for debugging)"
  value = {
    key_path                 = var.key_path
    expanded_path            = local.local_ssh_key_expanded_path
    file_exists              = local.local_ssh_key_file_exists
    file_content_length      = length(local.local_ssh_key_file_content)
    has_content              = length(local.local_ssh_key_file_content) > 0
    local_ssh_key_exists     = local.local_ssh_key_exists
    default_key_name         = local.default_key_name
    key_pair_will_be_created = local.local_ssh_key_exists
  }
}

output "key_pair_id" {
  description = "ID of the auto-created EC2 Key Pair (if key_path file exists and is not empty)"
  value       = local.local_ssh_key_exists ? aws_key_pair.main[0].id : null
}

output "dns_names" {
  description = "Map of DNS names for EC2 instances"
  value       = local.dns_enabled ? local.instance_dns_names : {}
}

output "dns_name" {
  description = "DNS name of the first EC2 instance"
  value       = local.dns_enabled && length(local.instance_dns_names) > 0 ? values(local.instance_dns_names)[0] : null
}

output "dns_names_private" {
  description = "Map of private/internal DNS names for EC2 instances"
  value       = local.dns_enabled && local.private_hosted_zone_name != null ? local.instance_private_dns_names : {}
}

output "dns_name_private" {
  description = "Private/internal DNS name of the first EC2 instance"
  value       = local.dns_enabled && local.private_hosted_zone_name != null && length(local.instance_private_dns_names) > 0 ? values(local.instance_private_dns_names)[0] : null
}

output "jump_enabled" {
  description = "Whether jump server is enabled on the EC2 instance"
  value       = var.enable_jump
}

output "gitlab_enabled" {
  description = "Whether GitLab is enabled on the EC2 instance"
  value       = var.gitlab_enabled
}

output "netbird_enabled" {
  description = "Whether NetBird is enabled on the EC2 instance"
  value       = var.netbird_enabled
}

output "netbird_setup_key" {
  description = "NetBird setup key for connecting to the NetBird network (sensitive)"
  sensitive   = true
  value       = var.netbird_enabled ? var.netbird_setup_key : null
}

output "gitlab_access_url" {
  description = "GitLab web access URL (HTTP/HTTPS) - uses external_url if set, otherwise DNS name or IP address"
  value = var.gitlab_enabled ? {
    for k, v in local.instances_output : k => (
      var.gitlab_external_url != null && var.gitlab_external_url != "" ? var.gitlab_external_url : (
        local.dns_enabled && contains(keys(local.instance_dns_names), k) ? "http://${local.instance_dns_names[k]}:${var.gitlab_http_port}" : "http://${v.public_ip}:${var.gitlab_http_port}"
      )
    )
  } : {}
}

output "gitlab_https_url" {
  description = "GitLab HTTPS access URL - uses project-based DNS name (e.g., gitlab.production.aws.hanyouqing.com) if ALB and DNS are enabled with HTTPS, otherwise uses external_url if it's HTTPS, otherwise null"
  value = var.gitlab_enabled && var.enable_alb && local.alb_protocol_resolved == "HTTPS" ? (
    var.gitlab_external_url != null && var.gitlab_external_url != "" && startswith(var.gitlab_external_url, "https://") ? var.gitlab_external_url : (
      local.dns_enabled && local.project_dns_name != null ? "https://${local.project_dns_name}" : (
        length(aws_lb.main) > 0 ? "https://${aws_lb.main[0].dns_name}" : null
      )
    )
  ) : null
}

output "jump_access_url" {
  description = "Jump server web access URL (HTTP) - uses DNS name if available, otherwise IP address"
  value = var.enable_jump ? {
    for k, v in local.instances_output : k => "http://${local.dns_enabled && contains(keys(local.instance_dns_names), k) ? local.instance_dns_names[k] : v.public_ip}:${var.jump_http_port}"
  } : {}
}

output "jump_https_url" {
  description = "Jump server HTTPS access URL - uses project-based DNS name (e.g., jump.production.aws.hanyouqing.com) if ALB and DNS are enabled with HTTPS, otherwise null"
  value = var.enable_jump && var.enable_alb && local.alb_protocol_resolved == "HTTPS" ? (
    local.dns_enabled && local.project_dns_name != null ? "https://${local.project_dns_name}" : (
      length(aws_lb.main) > 0 ? "https://${aws_lb.main[0].dns_name}" : null
    )
  ) : null
}

output "jump_ssh_port" {
  description = "Jump server SSH port"
  value       = var.enable_jump ? var.jump_ssh_port : null
}

output "jump_rdp_port" {
  description = "Jump server RDP port"
  value       = var.enable_jump ? var.jump_rdp_port : null
}

output "jump_db_password" {
  description = "Jump server database password (sensitive)"
  sensitive   = true
  value       = var.enable_jump ? (var.jump_db_password != null ? var.jump_db_password : (length(random_password.jump_db) > 0 ? random_password.jump_db[0].result : null)) : null
}

output "jump_redis_password" {
  description = "Jump server Redis password (sensitive)"
  sensitive   = true
  value       = var.enable_jump ? (var.jump_redis_password != null ? var.jump_redis_password : (length(random_password.jump_redis) > 0 ? random_password.jump_redis[0].result : null)) : null
}

output "jump_secret_key" {
  description = "Jump server SECRET_KEY (sensitive, auto-generated on server if not provided)"
  sensitive   = true
  value       = var.enable_jump ? var.jump_secret_key : null
}

output "jump_bootstrap_token" {
  description = "Jump server BOOTSTRAP_TOKEN (sensitive, auto-generated on server if not provided)"
  sensitive   = true
  value       = var.enable_jump ? var.jump_bootstrap_token : null
}

output "jump_admin_info" {
  description = "Jump server Web UI admin credentials and access information"
  sensitive   = false
  value = var.enable_jump ? join("\n", [
    "⚠️  Jump server Web UI Access:",
    "==============================",
    "",
    "🌐 Web UI URL:",
    join("\n", [for k, v in local.instances_output : "   http://${local.dns_enabled && contains(keys(local.instance_dns_names), k) ? local.instance_dns_names[k] : v.public_ip}:${var.jump_http_port}"]),
    "",
    "👤 Default Admin Credentials:",
    "   Username: admin",
    "   Password: admin",
    "",
    "📝 Important:",
    "   - Default password is 'admin' - CHANGE IT IMMEDIATELY after first login!",
    "   - If password was changed, check installation logs or database",
    "   - To reset password, see 'jump_password_reset' output",
    "",
    "🔍 Check Installation Logs for Admin Password:",
    "   ssh -i ~/.ssh/${var.name_prefix}-${var.environment} ubuntu@<ec2-instance-ip>",
    "   sudo cat /opt/jumpserver-installer-*/install-output.log | grep -i 'admin\\|password\\|credential'",
    "   sudo cat /var/log/jumpserver-install.log | grep -i 'admin\\|password\\|credential'"
  ]) : "Jump server not enabled"
}

output "ssm_session_manager_enabled" {
  description = "Whether SSM Session Manager is enabled for instances"
  value       = var.enable_ssm_session_manager
}

output "ssm_session_commands" {
  description = "SSM Session Manager commands to connect to instances (if enabled)"
  value = var.enable_ssm_session_manager ? {
    for k, v in local.instances_output : k => "aws ssm start-session --target ${v.id}"
  } : {}
}

# Auto Scaling Group outputs
output "asg_id" {
  description = "ID of the Auto Scaling Group (if enabled)"
  value       = var.enable_autoscaling && length(aws_autoscaling_group.main) > 0 ? aws_autoscaling_group.main[0].id : null
}

output "asg_name" {
  description = "Name of the Auto Scaling Group (if enabled)"
  value       = var.enable_autoscaling && length(aws_autoscaling_group.main) > 0 ? aws_autoscaling_group.main[0].name : null
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group (if enabled)"
  value       = var.enable_autoscaling && length(aws_autoscaling_group.main) > 0 ? aws_autoscaling_group.main[0].arn : null
}

output "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = var.enable_autoscaling && length(aws_autoscaling_group.main) > 0 ? aws_autoscaling_group.main[0].min_size : null
}

output "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = var.enable_autoscaling && length(aws_autoscaling_group.main) > 0 ? aws_autoscaling_group.main[0].max_size : null
}

output "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = var.enable_autoscaling && length(aws_autoscaling_group.main) > 0 ? aws_autoscaling_group.main[0].desired_capacity : null
}

output "launch_template_id" {
  description = "ID of the Launch Template (if ASG enabled)"
  value       = var.enable_autoscaling && length(aws_launch_template.main) > 0 ? aws_launch_template.main[0].id : null
}

output "launch_template_arn" {
  description = "ARN of the Launch Template (if ASG enabled)"
  value       = var.enable_autoscaling && length(aws_launch_template.main) > 0 ? aws_launch_template.main[0].arn : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Logs group (if enabled)"
  value       = var.cloudwatch_logs_enabled && length(aws_cloudwatch_log_group.main) > 0 ? aws_cloudwatch_log_group.main[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Logs group (if enabled)"
  value       = var.cloudwatch_logs_enabled && length(aws_cloudwatch_log_group.main) > 0 ? aws_cloudwatch_log_group.main[0].arn : null
}

output "jump_password_reset" {
  description = "How to reset jump server Web UI admin password"
  sensitive   = false
  value = var.enable_jump ? join("\n", [
    "⚠️  Reset Jump server Admin Password:",
    "=====================================",
    "",
    "Method 1: Via Database (Recommended):",
    "--------------------------------------",
    "1. SSH to EC2 instance:",
    "   ssh -i ~/.ssh/${var.name_prefix}-${var.environment} ubuntu@<ec2-instance-ip>",
    "",
    "2. Get database password:",
    "   terraform output -raw jumpserver_db_password",
    "",
    "3. Connect to database:",
    "   mysql -h ${var.jump_db_host} -P ${var.jump_db_port} -u ${var.jump_db_user} -p",
    "",
    "4. Reset admin password (replace 'newpassword' with your password):",
    "   USE ${var.jump_db_name};",
    "   UPDATE jms_user SET password='pbkdf2_sha256$<hash>' WHERE username='admin';",
    "",
    "   Or use Django shell to generate hash:",
    "   cd /opt/jumpserver-installer-*",
    "   docker exec -it jms_core python /opt/jumpserver/apps/jumpserver/apps.py shell",
    "   from django.contrib.auth.hashers import make_password",
    "   make_password('your_new_password')",
    "",
    "Method 2: Via Jump server CLI:",
    "------------------------------",
    "1. SSH to EC2 instance",
    "2. cd /opt/jumpserver-installer-*",
    "3. ./jmsctl.sh restart",
    "4. Access Web UI and use 'Forgot Password' feature",
    "",
    "Method 3: Reinstall (Last Resort):",
    "-----------------------------------",
    "1. Backup database: mysqldump -u ${var.jump_db_user} -p ${var.jump_db_name} > backup.sql",
    "2. Remove marker: sudo rm /var/lib/cloud/jumpserver-installed",
    "3. Re-run userdata script"
  ]) : "Jump server not enabled"
}

output "zzz_sensitive_access_info" {
  description = "🔐 SENSITIVE: Access information for sensitive data (passwords, tokens, keys, etc.)"
  sensitive   = true
  value = join("\n", compact([
    var.enable_jump ? join("\n", [
      "⚠️  JumpServer Sensitive Information:",
      "=====================================",
      "",
      "📋 Passwords and Tokens:",
      "------------------------",
      "",
      "1. Database Password:",
      "   terraform output -raw jump_db_password",
      "",
      "2. Redis Password:",
      "   terraform output -raw jump_redis_password",
      "",
      "3. Secret Key (if provided via variable):",
      "   terraform output -raw jump_secret_key",
      "   (Otherwise, check server: sudo cat /root/.jumpserver-secret-key)",
      "",
      "4. Bootstrap Token (if provided via variable):",
      "   terraform output -raw jump_bootstrap_token",
      "   (Otherwise, check server: sudo cat /root/.jumpserver-bootstrap-token)",
      "",
      "5. Web UI Admin Password:",
      "   Check: terraform output jump_admin_info",
      "   Reset: terraform output jump_password_reset",
      "",
      "6. Get all passwords at once:",
      "   terraform output -raw jump_db_password jump_redis_password",
      "",
    ]) : null,
    var.netbird_enabled ? join("\n", [
      var.enable_jump ? "" : null,
      "⚠️  NetBird Sensitive Information:",
      "===================================",
      "",
      "📋 Setup Key:",
      "-------------",
      "",
      "1. NetBird Setup Key:",
      "   terraform output -raw netbird_setup_key",
      "   (Required for NetBird VPN connection)",
      "",
      "2. Management URL (if self-hosted):",
      var.netbird_management_url != null ? "   ${nonsensitive(var.netbird_management_url)}" : "   Default (cloud)",
      "",
    ]) : null,
    join("\n", compact([
      (var.enable_jump || var.netbird_enabled) ? "" : null,
      "⚠️  IMPORTANT: Never commit sensitive values to version control!",
      "",
      "📝 Notes:",
      "   - If passwords were auto-generated, they are stored in Terraform state",
      "   - If SECRET_KEY/BOOTSTRAP_TOKEN were auto-generated, they are saved on the server",
      "   - Web UI default admin password should be changed immediately after first login",
      "   - Use 'terraform output -raw <output_name>' to get individual sensitive values",
    ])),
  ]))
}

output "zzz_sensitive_reminder" {
  description = "⚠️  REMINDER: How to access sensitive information (passwords, tokens, etc.)"
  sensitive   = false
  value = var.enable_jump || var.netbird_enabled ? join("\n", compact([
    "⚠️  Sensitive Information Access:",
    "=================================",
    "",
    "📋 To access sensitive information (passwords, tokens, keys):",
    "   terraform output zzz_sensitive_access_info",
    "",
    "⚠️  IMPORTANT: This output contains sensitive data and is marked as sensitive.",
    "   Use 'terraform output -raw zzz_sensitive_access_info' to view the content.",
    "",
    "📝 Individual sensitive outputs:",
    var.enable_jump ? join("\n", [
      "   - Database Password: terraform output -raw jump_db_password",
      "   - Redis Password: terraform output -raw jump_redis_password",
      "   - Secret Key: terraform output -raw jump_secret_key",
      "   - Bootstrap Token: terraform output -raw jump_bootstrap_token",
    ]) : null,
    var.netbird_enabled ? "   - NetBird Setup Key: terraform output -raw netbird_setup_key" : null,
  ])) : "No sensitive information configured"
}

# ==============================================================================
# Application Load Balancer (ALB) Outputs
# ==============================================================================

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = var.enable_alb && length(aws_lb.main) > 0 ? aws_lb.main[0].id : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.enable_alb && length(aws_lb.main) > 0 ? aws_lb.main[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.enable_alb && length(aws_lb.main) > 0 ? aws_lb.main[0].dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.enable_alb && length(aws_lb.main) > 0 ? aws_lb.main[0].zone_id : null
}

output "alb_target_group_id" {
  description = "ID of the ALB target group"
  value       = var.enable_alb && length(aws_lb_target_group.main) > 0 ? aws_lb_target_group.main[0].id : null
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = var.enable_alb && length(aws_lb_target_group.main) > 0 ? aws_lb_target_group.main[0].arn : null
}

output "alb_listener_id" {
  description = "ID of the ALB listener"
  value       = var.enable_alb && length(aws_lb_listener.main) > 0 ? aws_lb_listener.main[0].id : null
}

output "alb_listener_arn" {
  description = "ARN of the ALB listener"
  value       = var.enable_alb && length(aws_lb_listener.main) > 0 ? aws_lb_listener.main[0].arn : null
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.enable_alb && length(aws_security_group.alb) > 0 ? aws_security_group.alb[0].id : null
}

# ==============================================================================
# Classic Load Balancer (ELB) Outputs
# ==============================================================================

output "elb_id" {
  description = "ID of the Classic Load Balancer"
  value       = var.enable_elb && length(aws_elb.main) > 0 ? aws_elb.main[0].id : null
}

output "elb_name" {
  description = "Name of the Classic Load Balancer"
  value       = var.enable_elb && length(aws_elb.main) > 0 ? aws_elb.main[0].name : null
}

output "elb_dns_name" {
  description = "DNS name of the Classic Load Balancer"
  value       = var.enable_elb && length(aws_elb.main) > 0 ? aws_elb.main[0].dns_name : null
}

output "elb_zone_id" {
  description = "Zone ID of the Classic Load Balancer"
  value       = var.enable_elb && length(aws_elb.main) > 0 ? aws_elb.main[0].zone_id : null
}

output "elb_source_security_group_id" {
  description = "ID of the source security group for ELB"
  value       = var.enable_elb && length(aws_elb.main) > 0 ? aws_elb.main[0].source_security_group_id : null
}

output "elb_security_group_id" {
  description = "ID of the ELB security group"
  value       = var.enable_elb && length(aws_security_group.elb) > 0 ? aws_security_group.elb[0].id : null
}

# ==============================================================================
# Backward Compatibility Outputs (deprecated, use instance_* outputs instead)
# ==============================================================================

output "jump_instance_id" {
  description = "[DEPRECATED] ID of the first EC2 instance. Use instance_id instead."
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].id : null
}

output "jump_instance_public_ip" {
  description = "[DEPRECATED] Public IP address of the first EC2 instance. Use instance_public_ip instead."
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].public_ip : null
}

output "jump_instance_private_ip" {
  description = "[DEPRECATED] Private IP address of the first EC2 instance. Use instance_private_ip instead."
  value       = length(local.instances_output) > 0 ? values(local.instances_output)[0].private_ip : null
}

output "jump_security_group_id" {
  description = "[DEPRECATED] ID of the security group. Use security_group_id instead."
  value       = aws_security_group.main.id
}

output "jump_instances" {
  description = "[DEPRECATED] Map of all EC2 instances. Use instances instead."
  value = {
    for k, v in local.instances_output : k => {
      id         = v.id
      arn        = v.arn
      public_ip  = v.public_ip
      private_ip = v.private_ip
      public_dns = v.public_dns
      name       = local.instances[k].name
    }
  }
}

output "jump_instance_ids" {
  description = "[DEPRECATED] Map of instance IDs by instance name. Use instance_ids instead."
  value = {
    for k, v in local.instances_output : k => v.id
  }
}

output "jump_instance_public_ips" {
  description = "[DEPRECATED] Map of public IP addresses by instance name. Use instance_public_ips instead."
  value = {
    for k, v in local.instances_output : k => v.public_ip
  }
}

output "jump_instance_private_ips" {
  description = "[DEPRECATED] Map of private IP addresses by instance name. Use instance_private_ips instead."
  value = {
    for k, v in local.instances_output : k => v.private_ip
  }
}

output "jump_dns_names" {
  description = "[DEPRECATED] Map of DNS names for EC2 instances. Use dns_names instead."
  value       = local.dns_enabled ? local.instance_dns_names : {}
}

output "jumpserver_enabled" {
  description = "[DEPRECATED] Whether jump server is enabled. Use jump_enabled instead."
  value       = var.enable_jump
}

output "jumpserver_access_url" {
  description = "[DEPRECATED] Jump server web access URL map. Use jump_access_url instead."
  value = var.enable_jump ? {
    for k, v in local.instances_output : k => "http://${local.dns_enabled && contains(keys(local.instance_dns_names), k) ? local.instance_dns_names[k] : v.public_ip}:${var.jump_http_port}"
  } : {}
}

# Reminder Outputs (zzz_ prefix ensures they appear last)
# ==============================================================================

output "zzz_reminder_access_commands" {
  description = "⚠️ REMINDER: Access commands and important information after EC2 deployment"
  sensitive   = false
  value = <<-EOT
⚠️  REMINDER: EC2 Instance Access and Post-Deployment Tasks
============================================================

Instance Information:
${var.instance_count > 0 || length(var.instances) > 0 ? join("\n", [
  "- Instance Count: ${var.instance_count > 0 ? var.instance_count : length(var.instances)}",
  "  * Get Instance IDs: terraform output instance_ids",
  "  * Get Public IPs: terraform output instance_public_ips",
  "  * Get Private IPs: terraform output instance_private_ips",
  var.dns_enabled ? "  * Get DNS Names: terraform output dns_names" : "",
  "  * Get Instance Details: terraform output instances",
  ]) : var.enable_autoscaling ? "- Auto Scaling Group enabled (instances managed by ASG)" : "- No instances configured"}

${var.enable_autoscaling ? join("\n", [
  "- Auto Scaling Group: Enabled",
  "  * Min Size: ${var.asg_min_size}",
  "  * Max Size: ${var.asg_max_size}",
  "  * Desired Capacity: ${var.asg_desired_capacity}",
  "  * Use 'terraform output asg_name' to get ASG name",
  "  * Use 'terraform output launch_template_id' to get launch template ID",
  ]) : ""}

Access Methods:
${var.enable_ssm_session_manager ? join("\n", [
  "1. SSM Session Manager (Recommended - no SSH key needed):",
  "   # Get instance ID first:",
  "   terraform output instance_ids",
  "   # Then connect:",
  "   aws ssm start-session --target <instance-id>",
  "",
  "   # Or use the output command:",
  "   terraform output -raw ssm_session_commands",
  "",
  ]) : ""}# SSH Access
# Get SSH commands with proper key names and IPs:
terraform output -raw ssh_commands
# Or get individual values:
# terraform output instance_public_ips
# terraform output key_pair_name

${var.enable_jump ? join("\n", [
  "",
  "JumpServer Access:",
  "# Get JumpServer access URLs:",
  "terraform output jump_access_url",
  "",
  "# JumpServer Configuration:",
  "  * SSH Port: ${var.jump_ssh_port}",
  "  * RDP Port: ${var.jump_rdp_port}",
  "  * HTTP Port: ${var.jump_http_port}",
  nonsensitive(var.jump_db_host) != "localhost" ? "  * Database Host: ${nonsensitive(var.jump_db_host)}:${var.jump_db_port}" : "  * Database Host: localhost",
  nonsensitive(var.jump_redis_host) != "localhost" ? "  * Redis Host: ${nonsensitive(var.jump_redis_host)}:${var.jump_redis_port}" : "  * Redis Host: localhost",
  "",
  "⚠️  IMPORTANT: JumpServer requires database and Redis setup:",
  "   - Ensure database and Redis services are accessible from the EC2 instance",
  "   - Get sensitive information: terraform output zzz_sensitive_access_info",
  ]) : ""}

${var.gitlab_enabled ? join("\n", [
  "",
  "GitLab Access:",
  "# Get GitLab access URLs:",
  "terraform output gitlab_access_url",
  "",
  "# GitLab Configuration:",
  "  * SSH Port: ${var.gitlab_ssh_port}",
  "  * HTTP Port: ${var.gitlab_http_port}",
  "  * HTTPS Port: ${var.gitlab_https_port}",
  "",
  "⚠️  IMPORTANT: GitLab initial setup:",
  "   - Access the web UI to set root password",
  "   - Configure external URL if not set: gitlab_external_url",
  ]) : ""}

${var.netbird_enabled ? join("\n", [
  "",
  "NetBird VPN:",
  "  * Status: Enabled",
  "  * Setup Key: Check if configured (use terraform output to verify)",
  var.netbird_management_url != null ? "  * Management URL: ${nonsensitive(var.netbird_management_url)}" : "  * Management URL: Default (cloud)",
  "",
  "⚠️  IMPORTANT: NetBird setup:",
  "   - Verify setup key is configured: netbird_setup_key",
  "   - Get setup key from NetBird Management Dashboard if not set",
  "   - Check NetBird status: sudo netbird status",
  "   - View logs: sudo journalctl -u netbird -f",
  ]) : ""}

${var.enable_eip ? join("\n", [
  "",
  "Elastic IP:",
  "  * Status: Enabled",
  "  * Elastic IPs are attached to instances for stable public IP addresses",
  "  * Get Elastic IPs: terraform output elastic_ips",
  ]) : ""}

${var.enable_alb ? join("\n", [
  "",
  "Application Load Balancer:",
  "  * Get ALB DNS Name: terraform output alb_dns_name",
  "  * Get ALB ARN: terraform output alb_arn",
  "  * Listener Port: ${var.alb_port}",
  "  * Target Port: ${var.alb_target_port}",
  ]) : ""}

${var.enable_elb ? join("\n", [
  "",
  "Classic Load Balancer:",
  "  * Get ELB DNS Name: terraform output elb_dns_name",
  "  * Listener Port: ${var.elb_listener_port}",
  "  * Instance Port: ${var.elb_instance_port}",
  ]) : ""}

${var.cloudwatch_logs_enabled ? join("\n", [
  "",
  "CloudWatch Logs:",
  "  * Get Log Group Name: terraform output cloudwatch_log_group_name",
  "  * Retention: ${var.cloudwatch_logs_retention_days} days",
  "  * View logs: aws logs tail <log-group-name> --follow",
  ]) : ""}

${var.cloudwatch_metrics_enabled ? join("\n", [
  "",
  "CloudWatch Metrics:",
  "  * Status: Enabled",
  "  * View metrics in AWS Console: CloudWatch > Metrics",
  ]) : ""}

${var.dns_enabled ? join("\n", [
  "",
  "DNS Configuration:",
  "  * Domain: ${var.domain != null ? nonsensitive(var.domain) : "N/A"}",
  "  * DNS Records: Created",
  "  * TTL: ${var.dns_ttl} seconds",
  "  * Get DNS names: terraform output dns_names",
]) : ""}

Pending Tasks:
${var.enable_jump ? "1. JumpServer:\n   - Verify database and Redis connectivity\n   - Access web UI and complete initial setup\n   - Configure admin user\n   - Get sensitive information: terraform output zzz_sensitive_access_info\n" : ""}${var.gitlab_enabled ? "1. GitLab:\n   - Access web UI and set root password\n   - Configure external URL if needed\n   - Set up initial project\n" : ""}${var.netbird_enabled ? "1. NetBird:\n   - Verify setup key is configured\n   - Get sensitive information: terraform output zzz_sensitive_access_info\n" : ""}${var.enable_alb || var.enable_elb ? "2. Load Balancer:\n   - Verify health checks are passing\n   - Update DNS records if needed\n" : ""}${var.dns_enabled ? "3. DNS:\n   - Verify DNS records are resolving correctly\n   - Get DNS names: terraform output dns_names\n   - Check DNS propagation: dig <dns-name>\n" : ""}4. Security:
   - Review security group rules
   - Verify IAM permissions are correct
   - Check CloudWatch logs for any errors

5. Monitoring:
${var.cloudwatch_logs_enabled ? "   - Monitor CloudWatch Logs for application errors\n" : ""}${var.cloudwatch_metrics_enabled ? "   - Set up CloudWatch alarms for key metrics\n" : ""}   - Review instance metrics in CloudWatch

Applied at: ${timestamp()}
EOT
}

output "zzz_reminders" {
  description = "📝 REMINDER: Useful commands and next steps after EC2 deployment"
  sensitive   = false
  value = <<-EOT
📝  REMINDER: EC2 Module Deployment Complete
============================================

Your EC2 instances have been successfully deployed. Here are some useful commands and next steps:

1. Access Instances
-------------------
${var.enable_ssm_session_manager ? join("\n", [
  "# SSM Session Manager (Recommended - no SSH key needed)",
  "aws ssm start-session --target <instance-id>",
  "",
  "# Or use the output command:",
  "terraform output -raw ssm_session_commands",
  "",
  ]) : ""}# SSH Access
# Use the output command to get SSH commands with proper key names:
terraform output -raw ssh_commands
# Or check zzz_reminder_access_commands for detailed access information

2. View Instance Information
-----------------------------
# List all instances
terraform output instances

# Get instance IDs
terraform output instance_ids

# Get public IPs
terraform output instance_public_ips

# Get private IPs
terraform output instance_private_ips

${var.dns_enabled ? join("\n", [
  "# Get DNS names",
  "terraform output dns_names",
  "",
  ]) : ""}

3. Application-Specific Access
------------------------------
${var.enable_jump ? join("\n", [
  "# JumpServer Web UI",
  "terraform output jump_access_url",
  "",
  "# JumpServer SSH",
  "# Check zzz_reminder_access_commands for SSH access details with proper key names",
  "",
  ]) : ""}${var.gitlab_enabled ? join("\n", [
  "# GitLab Web UI",
  "terraform output gitlab_access_url",
  "",
  "# GitLab SSH (for Git operations)",
  "# Check zzz_reminder_access_commands for SSH access details with proper key names",
  "",
  ]) : ""}${var.netbird_enabled ? join("\n", [
  "# NetBird Status",
  "sudo netbird status",
  "",
  "# NetBird Logs",
  "sudo journalctl -u netbird -f",
  "",
  ]) : ""}

4. Monitoring and Logs
-----------------------
${var.cloudwatch_logs_enabled ? join("\n", [
  "# Get CloudWatch Log Group Name:",
  "terraform output cloudwatch_log_group_name",
  "",
  "# View CloudWatch Logs",
  "aws logs tail <log-group-name> --follow",
  "",
  "# List log streams",
  "aws logs describe-log-streams --log-group-name <log-group-name>",
  "",
  ]) : ""}# View instance metrics in AWS Console
# CloudWatch > Metrics > EC2 > Per-Instance Metrics

${var.cloudwatch_metrics_enabled ? "# CloudWatch Agent metrics are automatically collected\n" : ""}

5. Load Balancer (if enabled)
------------------------------
${var.enable_alb ? join("\n", [
  "# ALB DNS Name",
  "terraform output alb_dns_name",
  "",
  "# ALB ARN",
  "terraform output alb_arn",
  "",
  ]) : ""}${var.enable_elb ? join("\n", [
  "# ELB DNS Name",
  "terraform output elb_dns_name",
  "",
  ]) : ""}

6. Auto Scaling Group (if enabled)
-----------------------------------
${var.enable_autoscaling ? join("\n", [
  "# ASG Information",
  "terraform output asg_id",
  "terraform output asg_name",
  "",
  "# View ASG instances",
  "aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $(terraform output -raw asg_name)",
  "",
]) : ""}

7. Troubleshooting
-------------------
# View instance status
aws ec2 describe-instances --instance-ids <instance-id>

# View security group rules
aws ec2 describe-security-groups --group-ids <security-group-id>

# View CloudWatch Logs for errors
${var.cloudwatch_logs_enabled ? "# Get log group name first: terraform output cloudwatch_log_group_name\naws logs filter-log-events --log-group-name <log-group-name> --filter-pattern ERROR\n" : ""}# Connect via SSM Session Manager (if enabled)
${var.enable_ssm_session_manager ? "aws ssm start-session --target <instance-id>\n" : ""}

8. Common Operations
---------------------
# Stop instance
aws ec2 stop-instances --instance-ids <instance-id>

# Start instance
aws ec2 start-instances --instance-ids <instance-id>

# Reboot instance
aws ec2 reboot-instances --instance-ids <instance-id>

# View instance console output
aws ec2 get-console-output --instance-id <instance-id>

9. Security Best Practices
--------------------------
- Use SSM Session Manager instead of SSH when possible
- Regularly update instances: sudo apt update && sudo apt upgrade
- Review security group rules regularly
- Enable CloudWatch Logs for audit trails
- Use IAM roles instead of access keys
- Enable EBS encryption (already enabled: ${var.ebs_encrypted})

10. Cost Optimization
---------------------
- Use Spot instances for non-production workloads
- Right-size instances based on actual usage
- Enable CloudWatch detailed monitoring only when needed
- Use Auto Scaling Groups to scale based on demand
- Review and terminate unused instances regularly

For more information, see the module README: https://github.com/hanyouqing/terraform-aws-modules/tree/main/ec2

Last Applied: ${timestamp()}
EOT
}

