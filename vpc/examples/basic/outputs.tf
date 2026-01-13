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

output "security_group_jump_id" {
  description = "ID of the jump security group"
  value       = module.vpc.security_group_jump_id
}

output "security_group_public_id" {
  description = "ID of the public security group"
  value       = module.vpc.security_group_public_id
}

output "security_group_private_id" {
  description = "ID of the private security group"
  value       = module.vpc.security_group_private_id
}

output "security_group_database_id" {
  description = "ID of the database security group"
  value       = module.vpc.security_group_database_id
}

