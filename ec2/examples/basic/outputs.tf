output "ec2_name" {
  description = "Name of the EC2 module"
  value       = module.ec2.ec2_name
}

output "instance_id" {
  description = "ID of the first EC2 instance"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the first EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the first EC2 instance"
  value       = module.ec2.instance_private_ip
}

output "security_group_id" {
  description = "ID of the security group (created or from VPC)"
  value       = module.ec2.security_group_id
}

output "instances" {
  description = "Map of all EC2 instances"
  value       = module.ec2.instances
}

output "instance_ids" {
  description = "Map of instance IDs by instance name"
  value       = module.ec2.instance_ids
}

# Reminder outputs (zzz_ prefix ensures they appear last)
output "zzz_reminder_access_commands" {
  description = "⚠️ REMINDER: Access commands and important information after EC2 deployment"
  value       = module.ec2.zzz_reminder_access_commands
}

output "zzz_reminders" {
  description = "📝 REMINDER: Useful commands and next steps after EC2 deployment"
  value       = module.ec2.zzz_reminders
}
