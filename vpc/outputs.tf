output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = local.name
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (list format, for backward compatibility)"
  value       = aws_subnet.public[*].id
}

output "public_subnet_ids_map" {
  description = "Map of public subnet IDs by name (format: {name => id})"
  value = {
    for idx, subnet in aws_subnet.public : "${local.name}-public-${substr(var.availability_zones[idx], -1, 1)}" => subnet.id
  }
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = local.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (list format, for backward compatibility)"
  value       = aws_subnet.private[*].id
}

output "private_subnet_ids_map" {
  description = "Map of private subnet IDs by name (format: {name => id})"
  value = {
    for idx, subnet in aws_subnet.private : "${local.name}-private-${substr(var.availability_zones[idx], -1, 1)}" => subnet.id
  }
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = local.private_subnets
}

output "database_subnet_ids" {
  description = "IDs of the database subnets (list format, for backward compatibility)"
  value       = aws_subnet.database[*].id
}

output "database_subnet_ids_map" {
  description = "Map of database subnet IDs by name (format: {name => id})"
  value = length(aws_subnet.database) > 0 ? {
    for idx, subnet in aws_subnet.database : "${local.name}-database-${substr(var.availability_zones[idx], -1, 1)}" => subnet.id
  } : {}
}

output "database_subnet_cidrs" {
  description = "CIDR blocks of the database subnets"
  value       = local.database_subnets
}

output "database_subnet_group_id" {
  description = "ID of the database subnet group (null if no database subnets)"
  value       = length(local.database_subnets) > 0 ? aws_db_subnet_group.main[0].id : null
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways (list format, for backward compatibility)"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_ids_map" {
  description = "Map of NAT Gateway IDs by name (format: {name => id})"
  value = length(aws_nat_gateway.main) > 0 ? {
    for idx, nat in aws_nat_gateway.main : "${local.name}-nat-${idx + 1}" => nat.id
  } : {}
}

output "nat_public_ips" {
  description = "Public IPs of the NAT Gateways (list format, for backward compatibility)"
  value       = aws_eip.nat[*].public_ip
}

output "nat_public_ips_map" {
  description = "Map of NAT Gateway public IPs by name (format: {name => public_ip})"
  value = length(aws_eip.nat) > 0 ? {
    for idx, eip in aws_eip.nat : "${local.name}-nat-${idx + 1}" => eip.public_ip
  } : {}
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = [aws_route_table.public.id]
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_ids" {
  description = "IDs of the database route tables"
  value       = aws_route_table.database[*].id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_log ? aws_flow_log.main[0].id : null
}

output "vpc_flow_log_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.vpc_flow_log[0].name : null
}

output "vpc_flow_log_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.vpc_flow_log[0].arn : null
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_default_security_group_id" {
  description = "ID of the default security group for the VPC"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "ID of the default route table for the VPC"
  value       = aws_vpc.main.default_route_table_id
}

output "vpc_main_route_table_id" {
  description = "ID of the main route table for the VPC"
  value       = aws_vpc.main.main_route_table_id
}

output "vpc_cidr_block_associations" {
  description = "CIDR block associations for the VPC"
  value       = data.aws_vpc.main.cidr_block_associations
}

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC (if enabled)"
  value       = try(aws_vpc.main.ipv6_cidr_block, null)
}

output "vpc_ipv6_association_id" {
  description = "IPv6 association ID for the VPC (if enabled)"
  value       = try(aws_vpc.main.ipv6_association_id, null)
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks of the public subnets"
  value       = var.enable_ipv6 ? aws_subnet.public[*].ipv6_cidr_block : []
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks of the private subnets"
  value       = var.enable_ipv6 ? aws_subnet.private[*].ipv6_cidr_block : []
}

output "database_subnet_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks of the database subnets"
  value       = var.enable_ipv6 ? aws_subnet.database[*].ipv6_cidr_block : []
}

# VPC Peering Outputs
output "vpc_peering_connection_ids" {
  description = "IDs of the VPC peering connections"
  value       = var.enable_vpc_peering ? { for k, v in aws_vpc_peering_connection.main : k => v.id } : {}
}

output "vpc_peering_connection_arns" {
  description = "ARNs of the VPC peering connections"
  value       = var.enable_vpc_peering ? { for k, v in aws_vpc_peering_connection.main : k => v.arn } : {}
}

# Transit Gateway Outputs
output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

output "transit_gateway_attachment_arn" {
  description = "ARN of the Transit Gateway VPC attachment"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway_vpc_attachment.main[0].arn : null
}

# CloudWatch Monitoring Outputs
output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value       = var.enable_cloudwatch_alarms ? concat([for k, v in aws_cloudwatch_metric_alarm.nat_gateway_bandwidth : v.arn], var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? [aws_cloudwatch_metric_alarm.vpc_flow_logs[0].arn] : []) : []
}

output "cost_anomaly_monitor_arn" {
  description = "ARN of the Cost Anomaly Detection monitor"
  value       = var.enable_cost_anomaly_detection ? aws_ce_anomaly_monitor.main[0].arn : null
}

output "cost_anomaly_subscription_arn" {
  description = "ARN of the Cost Anomaly Detection subscription"
  value       = var.enable_cost_anomaly_detection && var.cloudwatch_alarm_sns_topic_arn != null ? aws_ce_anomaly_subscription.main[0].arn : null
}

# Network ACL Outputs
output "network_acl_ids" {
  description = "IDs of the Network ACLs (if enabled)"
  value = var.enable_network_acls ? {
    public   = aws_network_acl.public[0].id
    private  = aws_network_acl.private[0].id
    database = aws_network_acl.database[0].id
    default  = aws_default_network_acl.main[0].id
  } : {}
}

# Default Security Group Output
output "default_security_group_id" {
  description = "ID of the default security group (restricted if restrict_default_security_group = true)"
  value       = var.restrict_default_security_group ? aws_default_security_group.main[0].id : aws_vpc.main.default_security_group_id
}

# Security Group Rule Counts Output
output "security_group_rule_counts" {
  description = "Security group rule counts for validation (AWS limit: 60 rules per direction)"
  value = {
    public = {
      ingress = local.public_sg_ingress_count
      egress  = local.public_sg_egress_count
      total   = local.public_sg_ingress_count + local.public_sg_egress_count
    }
    private = {
      ingress = local.private_sg_ingress_count
      egress  = local.private_sg_egress_count
      total   = local.private_sg_ingress_count + local.private_sg_egress_count
    }
    database = {
      ingress = local.database_sg_ingress_count
      egress  = local.database_sg_egress_count
      total   = local.database_sg_ingress_count + local.database_sg_egress_count
    }
    jump = {
      ingress = local.jump_sg_ingress_count
      egress  = local.jump_sg_egress_count
      total   = local.jump_sg_ingress_count + local.jump_sg_egress_count
    }
    vpc_endpoints = {
      ingress = local.vpc_endpoints_sg_ingress_count
      egress  = local.vpc_endpoints_sg_egress_count
      total   = local.vpc_endpoints_sg_ingress_count + local.vpc_endpoints_sg_egress_count
    }
  }
}

output "allowlist_prefix_list_id_ipv4" {
  description = "ID of the IPv4 Managed Prefix List for allowlist"
  value       = length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? aws_ec2_managed_prefix_list.allowlist_ipv4[0].id : null
}

output "allowlist_prefix_list_arn_ipv4" {
  description = "ARN of the IPv4 Managed Prefix List for allowlist"
  value       = length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? aws_ec2_managed_prefix_list.allowlist_ipv4[0].arn : null
}

output "allowlist_prefix_list_name_ipv4" {
  description = "Name of the IPv4 Managed Prefix List for allowlist"
  value       = length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? aws_ec2_managed_prefix_list.allowlist_ipv4[0].name : null
}

output "allowlist_prefix_list_id_ipv6" {
  description = "ID of the IPv6 Managed Prefix List for allowlist"
  value       = length(aws_ec2_managed_prefix_list.allowlist_ipv6) > 0 ? aws_ec2_managed_prefix_list.allowlist_ipv6[0].id : null
}

output "allowlist_prefix_list_arn_ipv6" {
  description = "ARN of the IPv6 Managed Prefix List for allowlist"
  value       = length(aws_ec2_managed_prefix_list.allowlist_ipv6) > 0 ? aws_ec2_managed_prefix_list.allowlist_ipv6[0].arn : null
}

output "allowlist_prefix_list_name_ipv6" {
  description = "Name of the IPv6 Managed Prefix List for allowlist"
  value       = length(aws_ec2_managed_prefix_list.allowlist_ipv6) > 0 ? aws_ec2_managed_prefix_list.allowlist_ipv6[0].name : null
}

# Allowlist Prefix List IDs Map
output "allowlist_prefix_list_ids_map" {
  description = "Map of allowlist prefix list IDs by name (format: {name => id})"
  value = merge(
    length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? {
      "${aws_ec2_managed_prefix_list.allowlist_ipv4[0].name}" = aws_ec2_managed_prefix_list.allowlist_ipv4[0].id
    } : {},
    length(aws_ec2_managed_prefix_list.allowlist_ipv6) > 0 ? {
      "${aws_ec2_managed_prefix_list.allowlist_ipv6[0].name}" = aws_ec2_managed_prefix_list.allowlist_ipv6[0].id
    } : {}
  )
}

# Allowlist Prefix List ARNs Map
output "allowlist_prefix_list_arns_map" {
  description = "Map of allowlist prefix list ARNs by name (format: {name => arn})"
  value = merge(
    length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? {
      "${aws_ec2_managed_prefix_list.allowlist_ipv4[0].name}" = aws_ec2_managed_prefix_list.allowlist_ipv4[0].arn
    } : {},
    length(aws_ec2_managed_prefix_list.allowlist_ipv6) > 0 ? {
      "${aws_ec2_managed_prefix_list.allowlist_ipv6[0].name}" = aws_ec2_managed_prefix_list.allowlist_ipv6[0].arn
    } : {}
  )
}

output "jump_security_group_id" {
  description = "ID of the jump security group"
  value       = aws_security_group.jump.id
}

output "jump_security_group_arn" {
  description = "ARN of the jump security group"
  value       = aws_security_group.jump.arn
}

output "jump_security_group_name" {
  description = "Name of the jump security group"
  value       = aws_security_group.jump.name
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public.id
}

output "public_security_group_arn" {
  description = "ARN of the public security group"
  value       = aws_security_group.public.arn
}

output "public_security_group_name" {
  description = "Name of the public security group"
  value       = aws_security_group.public.name
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private.id
}

output "private_security_group_arn" {
  description = "ARN of the private security group"
  value       = aws_security_group.private.arn
}

output "private_security_group_name" {
  description = "Name of the private security group"
  value       = aws_security_group.private.name
}

# Security Group IDs (separate outputs)
output "security_group_jump_id" {
  description = "ID of the jump security group"
  value       = aws_security_group.jump.id
}

output "security_group_public_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public.id
}

output "security_group_private_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private.id
}

output "security_group_database_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "database_security_group_arn" {
  description = "ARN of the database security group"
  value       = aws_security_group.database.arn
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].id : null
}

output "vpc_endpoints_security_group_arn" {
  description = "ARN of the VPC endpoints security group"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].arn : null
}

# Interface endpoints outputs (using for_each)
output "interface_endpoints" {
  description = "Map of all interface VPC endpoints (ECR DKR, ECR API, EKS, CloudWatch Logs, Secrets Manager)"
  value = {
    for k, v in aws_vpc_endpoint.interface : k => {
      id           = v.id
      arn          = v.arn
      dns_entry    = v.dns_entry
      service_name = v.service_name
    }
  }
}

# Gateway endpoints outputs (using for_each)
output "gateway_endpoints" {
  description = "Map of all gateway VPC endpoints (S3)"
  value = {
    for k, v in aws_vpc_endpoint.gateway : k => {
      id             = v.id
      arn            = v.arn
      prefix_list_id = v.prefix_list_id
      service_name   = v.service_name
    }
  }
}

# Individual endpoint outputs for backward compatibility
output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR Docker API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ecr_dkr"].id, null)
}

output "ecr_dkr_endpoint_dns_entry" {
  description = "DNS entries for the ECR Docker API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ecr_dkr"].dns_entry, null)
}

output "ecr_dkr_endpoint_arn" {
  description = "ARN of the ECR Docker API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ecr_dkr"].arn, null)
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ecr_api"].id, null)
}

output "ecr_api_endpoint_dns_entry" {
  description = "DNS entries for the ECR API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ecr_api"].dns_entry, null)
}

output "ecr_api_endpoint_arn" {
  description = "ARN of the ECR API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ecr_api"].arn, null)
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.gateway["s3"].id, null)
}

output "s3_endpoint_prefix_list_id" {
  description = "Prefix list ID of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.gateway["s3"].prefix_list_id, null)
}

output "s3_endpoint_arn" {
  description = "ARN of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.gateway["s3"].arn, null)
}

output "eks_endpoint_id" {
  description = "ID of the EKS API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["eks"].id, null)
}

output "eks_endpoint_dns_entry" {
  description = "DNS entries for the EKS API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["eks"].dns_entry, null)
}

output "eks_endpoint_arn" {
  description = "ARN of the EKS API VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["eks"].arn, null)
}

output "cloudwatch_logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["cloudwatch_logs"].id, null)
}

output "cloudwatch_logs_endpoint_dns_entry" {
  description = "DNS entries for the CloudWatch Logs VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["cloudwatch_logs"].dns_entry, null)
}

output "cloudwatch_logs_endpoint_arn" {
  description = "ARN of the CloudWatch Logs VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["cloudwatch_logs"].arn, null)
}

output "secretsmanager_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["secretsmanager"].id, null)
}

output "secretsmanager_endpoint_dns_entry" {
  description = "DNS entries for the Secrets Manager VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["secretsmanager"].dns_entry, null)
}

output "secretsmanager_endpoint_arn" {
  description = "ARN of the Secrets Manager VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["secretsmanager"].arn, null)
}

output "ssm_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ssm"].id, null)
}

output "ssm_endpoint_arn" {
  description = "ARN of the SSM VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["ssm"].arn, null)
}

output "sts_endpoint_id" {
  description = "ID of the STS VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["sts"].id, null)
}

output "sts_endpoint_arn" {
  description = "ARN of the STS VPC endpoint"
  value       = try(aws_vpc_endpoint.interface["sts"].arn, null)
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB Gateway VPC endpoint"
  value       = try(aws_vpc_endpoint.gateway["dynamodb"].id, null)
}

output "dynamodb_endpoint_prefix_list_id" {
  description = "Prefix list ID of the DynamoDB Gateway VPC endpoint"
  value       = try(aws_vpc_endpoint.gateway["dynamodb"].prefix_list_id, null)
}

output "dynamodb_endpoint_arn" {
  description = "ARN of the DynamoDB Gateway VPC endpoint"
  value       = try(aws_vpc_endpoint.gateway["dynamodb"].arn, null)
}

output "domain_name" {
  description = "Full domain name for the environment (e.g., production.example.com)"
  value       = var.domain != null ? "${var.environment}.${var.domain}" : null
}

output "base_domain" {
  description = "Base domain name (e.g., example.com)"
  value       = var.domain
}

output "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = var.domain != null ? aws_route53_zone.main[0].zone_id : null
}

output "hosted_zone_name" {
  description = "Name of the Route 53 hosted zone"
  value       = var.domain != null ? aws_route53_zone.main[0].name : null
}

output "hosted_zone_name_servers" {
  description = "Name servers for the Route 53 hosted zone (use these to configure NS records in parent domain)"
  value       = var.domain != null ? aws_route53_zone.main[0].name_servers : null
}

output "hosted_zone_name_servers_list" {
  description = "List of name servers for easy copy-paste (one per line)"
  value       = var.domain != null ? join("\n", aws_route53_zone.main[0].name_servers) : null
}

output "hosted_zone_ns_records" {
  description = "NS records formatted for DNS providers (e.g., Cloudflare). Add these NS records in the parent domain."
  value = var.domain != null ? {
    subdomain = var.environment
    type      = "NS"
    ttl       = 3600
    values    = aws_route53_zone.main[0].name_servers
  } : null
}

output "hosted_zone_delegation_instructions" {
  description = "Instructions for delegating the subdomain to Route53"
  value = var.domain != null ? join("\n", [
    "⚠️  DNS DELEGATION INSTRUCTIONS:",
    "",
    "To delegate ${var.environment}.${var.domain} to Route53, add the following NS records",
    "in your parent domain (${var.domain}) DNS provider (e.g., Cloudflare):",
    "",
    "Type: NS",
    "Name: ${var.environment}",
    "TTL: 3600 (or Auto)",
    "Values:",
    join("\n", [for ns in aws_route53_zone.main[0].name_servers : "  - ${ns}"]),
    "",
    "Important:",
    "- Add ALL ${length(aws_route53_zone.main[0].name_servers)} NS records listed above",
    "- Set Proxy status to \"DNS only\" (disable Cloudflare proxy if using Cloudflare)",
    "- DNS propagation may take up to 48 hours",
    "",
    "After adding NS records, verify with:",
    "dig NS ${var.environment}.${var.domain} +short"
  ]) : null
}

output "hosted_zone_arn" {
  description = "ARN of the Route 53 hosted zone"
  value       = var.domain != null ? aws_route53_zone.main[0].arn : null
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the environment domain"
  value       = var.domain != null ? aws_acm_certificate.environment[0].arn : null
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.domain != null ? aws_acm_certificate.environment[0].domain_name : null
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate validation"
  value       = var.domain != null ? aws_acm_certificate_validation.environment[0].id : null
}

output "private_hosted_zone_id" {
  description = "ID of the Route 53 private hosted zone (private-production.mini-verse.org)"
  value       = var.environment == "production" && var.domain != null ? aws_route53_zone.private[0].zone_id : null
}

output "private_hosted_zone_name" {
  description = "Name of the Route 53 private hosted zone (private-production.mini-verse.org)"
  value       = var.environment == "production" && var.domain != null ? aws_route53_zone.private[0].name : null
}

output "private_hosted_zone_arn" {
  description = "ARN of the Route 53 private hosted zone (private-production.mini-verse.org)"
  value       = var.environment == "production" && var.domain != null ? aws_route53_zone.private[0].arn : null
}

output "private_hosted_zone_name_servers" {
  description = "Name servers for the Route 53 private hosted zone (private-production.mini-verse.org)"
  value       = var.environment == "production" && var.domain != null ? aws_route53_zone.private[0].name_servers : null
}

# Route53 Zone IDs Map
output "route53_zone_ids_map" {
  description = "Map of Route53 hosted zone IDs by name (format: {name => zone_id})"
  value = merge(
    var.domain != null ? {
      "${aws_route53_zone.main[0].name}" = aws_route53_zone.main[0].zone_id
    } : {},
    var.environment == "production" && var.domain != null ? {
      "${aws_route53_zone.private[0].name}" = aws_route53_zone.private[0].zone_id
    } : {}
  )
}

# Route53 Zone ARNs Map
output "route53_zone_arns_map" {
  description = "Map of Route53 hosted zone ARNs by name (format: {name => arn})"
  value = merge(
    var.domain != null ? {
      "${aws_route53_zone.main[0].name}" = aws_route53_zone.main[0].arn
    } : {},
    var.environment == "production" && var.domain != null ? {
      "${aws_route53_zone.private[0].name}" = aws_route53_zone.private[0].arn
    } : {}
  )
}

# Route53 Zone Name Servers Map
output "route53_zone_name_servers_map" {
  description = "Map of Route53 hosted zone name servers by name (format: {name => [name_servers]})"
  value = merge(
    var.domain != null ? {
      "${aws_route53_zone.main[0].name}" = aws_route53_zone.main[0].name_servers
    } : {},
    var.environment == "production" && var.domain != null ? {
      "${aws_route53_zone.private[0].name}" = aws_route53_zone.private[0].name_servers
    } : {}
  )
}

# Reminder Outputs (zzz_ prefix ensures they appear last)
# ==============================================================================

output "zzz_allowlist_update_reminder" {
  description = "⚠️ REMINDER: Important tasks after VPC deployment"
  value = <<-EOT
⚠️  REMINDER: VPC Allowlist and Post-Deployment Tasks
=======================================================

Allowlist Information:
${length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? join("\n", [
  "- IPv4 Prefix List ID: ${aws_ec2_managed_prefix_list.allowlist_ipv4[0].id}",
  "- IPv4 Prefix List Name: ${aws_ec2_managed_prefix_list.allowlist_ipv4[0].name}"
  ]) : "- IPv4 Prefix List: Not configured"}
${length(aws_ec2_managed_prefix_list.allowlist_ipv6) > 0 ? join("\n", [
  "- IPv6 Prefix List ID: ${aws_ec2_managed_prefix_list.allowlist_ipv6[0].id}",
  "- IPv6 Prefix List Name: ${aws_ec2_managed_prefix_list.allowlist_ipv6[0].name}"
]) : "- IPv6 Prefix List: Not configured"}

Pending Tasks:
1. EKS Public Access:
   - Verify EKS cluster endpoint_public_access_cidrs uses VPC allowlist prefix list
   - Ensure EKS public access is properly restricted to allowlist IPs only

2. AWS ALB (Application Load Balancer):
   - ⚠️  IMPORTANT: ALB does NOT support direct prefix list binding
   - ALB can only use prefix list through security group rules
   - Check if any ALB security groups use 0.0.0.0/0 (allows all IPs)
   - Recommendation: Update ALB security group rules to use allowlist prefix list
   - Action: Add security group rules using prefix_list_ids instead of cidr_blocks

3. Other:
   - Review and update any other resources that should use allowlist
   - Consider adding allowlist rules to VPC public security group if needed

Applied at: ${timestamp()}
EOT
}

