output "ec2_name" {
  description = "Name of the EC2 module"
  value       = module.ec2.ec2_name
}

output "instances" {
  description = "Map of all EC2 instances"
  value       = module.ec2.instances
}

output "instance_ids" {
  description = "Map of instance IDs by instance name"
  value       = module.ec2.instance_ids
}

output "instance_public_ips" {
  description = "Map of public IP addresses by instance name"
  value       = module.ec2.instance_public_ips
}

output "instance_private_ips" {
  description = "Map of private IP addresses by instance name"
  value       = module.ec2.instance_private_ips
}

output "security_group_id" {
  description = "ID of the security group (created or from VPC)"
  value       = module.ec2.security_group_id
}

output "dns_names" {
  description = "Map of DNS names for EC2 instances"
  value       = module.ec2.dns_names
}

# Reminder outputs (zzz_ prefix ensures they appear last)
output "zzz_reminder_access_commands" {
  description = "⚠️ REMINDER: Access commands and important information after EC2 deployment"
  value       = module.ec2.zzz_reminder_access_commands
  sensitive   = false
}

output "zzz_reminders" {
  description = "📝 REMINDER: Useful commands and next steps after EC2 deployment"
  value       = module.ec2.zzz_reminders
  sensitive   = false
}
