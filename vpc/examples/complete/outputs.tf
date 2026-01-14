output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.vpc.vpc_name
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway"
  value       = module.vpc.internet_gateway_arn
}

output "nat_public_ips" {
  description = "Public IPs of NAT Gateways (list format)"
  value       = module.vpc.nat_public_ips
}

output "nat_public_ips_map" {
  description = "Map of NAT Gateway public IPs by name"
  value       = module.vpc.nat_public_ips_map
}

output "nat_gateway_public_ips" {
  description = "Map of NAT Gateway public IPs by name (format: {name => public_ip})"
  value       = module.vpc.nat_gateway_public_ips
}

output "allowlist_prefix_list_id_ipv4" {
  description = "ID of the IPv4 Managed Prefix List for allowlist"
  value       = module.vpc.allowlist_prefix_list_id_ipv4
}

output "allowlist_prefix_list_ids_map" {
  description = "Map of allowlist prefix list IDs by name"
  value       = module.vpc.allowlist_prefix_list_ids_map
}

output "allowlist_prefix_list_arns_map" {
  description = "Map of allowlist prefix list ARNs by name"
  value       = module.vpc.allowlist_prefix_list_arns_map
}

output "jump_security_group_id" {
  description = "ID of the jump security group"
  value       = module.vpc.jump_security_group_id
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = module.vpc.public_security_group_id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = module.vpc.private_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.vpc.database_security_group_id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = module.vpc.vpc_endpoints_security_group_id
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR Docker API VPC endpoint"
  value       = module.vpc.ecr_dkr_endpoint_id
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = module.vpc.s3_endpoint_id
}

output "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = module.vpc.hosted_zone_id
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the environment domain"
  value       = module.vpc.acm_certificate_arn
}

output "acm_certificate_id" {
  description = "ID of the ACM certificate"
  value       = module.vpc.acm_certificate_id
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = module.vpc.acm_certificate_domain_name
}

output "acm_certificate_subject_alternative_names" {
  description = "List of subject alternative names (SANs) for the ACM certificate"
  value       = module.vpc.acm_certificate_subject_alternative_names
}

output "acm_certificate_validation_method" {
  description = "Validation method used for the ACM certificate"
  value       = module.vpc.acm_certificate_validation_method
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate validation"
  value       = module.vpc.acm_certificate_status
}

output "acm_certificate_validation_record_fqdns" {
  description = "List of FQDNs for DNS validation records"
  value       = module.vpc.acm_certificate_validation_record_fqdns
}

output "hosted_zone_name" {
  description = "Name of the Route 53 hosted zone"
  value       = module.vpc.hosted_zone_name
}

output "hosted_zone_arn" {
  description = "ARN of the Route 53 hosted zone"
  value       = module.vpc.hosted_zone_arn
}

output "base_domain" {
  description = "Base domain name (e.g., example.com)"
  value       = module.vpc.base_domain
}

output "domain_name" {
  description = "Full domain name for the environment (e.g., production.example.com)"
  value       = module.vpc.domain_name
}

# Route53 NS Records Outputs (for DNS delegation)
output "hosted_zone_name_servers" {
  description = "Name servers for the Route 53 hosted zone (use these to configure NS records in parent domain)"
  value       = module.vpc.hosted_zone_name_servers
}

output "hosted_zone_name_servers_list" {
  description = "List of name servers for easy copy-paste (one per line)"
  value       = module.vpc.hosted_zone_name_servers_list
}

output "hosted_zone_ns_records" {
  description = "NS records formatted for DNS providers (e.g., Cloudflare). Add these NS records in the parent domain."
  value       = module.vpc.hosted_zone_ns_records
}

output "hosted_zone_ns_records_formatted" {
  description = "NS records in a formatted string for easy copy-paste to DNS providers"
  value       = module.vpc.hosted_zone_ns_records_formatted
}

output "hosted_zone_ns_records_cloudflare" {
  description = "NS records formatted specifically for Cloudflare DNS (JSON format)"
  value       = module.vpc.hosted_zone_ns_records_cloudflare
}

output "hosted_zone_ns_records_list" {
  description = "List of NS record values (name servers) for programmatic use"
  value       = module.vpc.hosted_zone_ns_records_list
}

output "hosted_zone_delegation_instructions" {
  description = "Detailed instructions for delegating the subdomain to Route53 in various DNS providers"
  value       = module.vpc.hosted_zone_delegation_instructions
}

# Private Route53 Hosted Zone Outputs (for internal services like Redis, Database, etc.)
output "private_hosted_zone_id" {
  description = "ID of the Route 53 private hosted zone for internal services (Redis, Database, etc.)"
  value       = module.vpc.private_hosted_zone_id
}

output "private_hosted_zone_name" {
  description = "Name of the Route 53 private hosted zone for internal services (e.g., development.example.com, same as public hosted zone)"
  value       = module.vpc.private_hosted_zone_name
}

output "private_hosted_zone_arn" {
  description = "ARN of the Route 53 private hosted zone for internal services"
  value       = module.vpc.private_hosted_zone_arn
}

# Map format outputs
output "public_subnet_ids_map" {
  description = "Map of public subnet IDs by name"
  value       = module.vpc.public_subnet_ids_map
}

output "private_subnet_ids_map" {
  description = "Map of private subnet IDs by name"
  value       = module.vpc.private_subnet_ids_map
}

output "database_subnet_ids_map" {
  description = "Map of database subnet IDs by name"
  value       = module.vpc.database_subnet_ids_map
}

output "nat_gateway_ids_map" {
  description = "Map of NAT Gateway IDs by name"
  value       = module.vpc.nat_gateway_ids_map
}

output "security_group_ids" {
  description = "IDs of all security groups (list format, for backward compatibility)"
  value       = module.vpc.security_group_ids
}

output "security_group_ids_map" {
  description = "Map of all security groups (format: {jump => id, public => id, private => id, database => id})"
  value       = module.vpc.security_group_ids_map
}

output "route53_zone_ids_map" {
  description = "Map of Route53 hosted zone IDs by name"
  value       = module.vpc.route53_zone_ids_map
}

output "route53_zone_arns_map" {
  description = "Map of Route53 hosted zone ARNs by name"
  value       = module.vpc.route53_zone_arns_map
}

output "route53_zone_name_servers_map" {
  description = "Map of Route53 hosted zone name servers by name"
  value       = module.vpc.route53_zone_name_servers_map
}

# Reminder outputs (zzz_ prefix ensures they appear last)
output "zzz_allowlist_update_reminder" {
  description = "⚠️ REMINDER: Important tasks after VPC deployment"
  value       = module.vpc.zzz_allowlist_update_reminder
}

output "zzz_reminders" {
  description = "📝 REMINDER: Complete examples for using VPC outputs in EC2, RDS, Redis, and other resources"
  value       = module.vpc.zzz_reminders
}
