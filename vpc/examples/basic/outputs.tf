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

# Route53 and ACM Certificate Outputs
output "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = module.vpc.hosted_zone_id
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

output "acm_certificate_status" {
  description = "Status of the ACM certificate validation"
  value       = module.vpc.acm_certificate_status
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
  description = "ID of the Route 53 private hosted zone for internal services"
  value       = module.vpc.private_hosted_zone_id
}

output "private_hosted_zone_name" {
  description = "Name of the Route 53 private hosted zone for internal services"
  value       = module.vpc.private_hosted_zone_name
}

output "private_hosted_zone_arn" {
  description = "ARN of the Route 53 private hosted zone for internal services"
  value       = module.vpc.private_hosted_zone_arn
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

