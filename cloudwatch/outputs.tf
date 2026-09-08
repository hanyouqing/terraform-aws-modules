output "log_group_names" {
  description = "Map of log group names"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "log_group_arns" {
  description = "Map of log group ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "alarm_arns" {
  description = "Map of alarm ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}
