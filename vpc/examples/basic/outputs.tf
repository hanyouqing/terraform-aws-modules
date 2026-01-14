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

# Reminder outputs (zzz_ prefix ensures they appear last)
output "zzz_allowlist_update_reminder" {
  description = "⚠️ REMINDER: Important tasks after VPC deployment"
  value       = module.vpc.zzz_allowlist_update_reminder
}

output "zzz_reminders" {
  description = "📝 REMINDER: Complete examples for using VPC outputs in EC2, RDS, Redis, and other resources"
  value       = module.vpc.zzz_reminders
}

