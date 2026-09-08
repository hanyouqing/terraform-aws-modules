output "topic_arns" {
  description = "Map of topic ARNs"
  value       = { for k, v in aws_sns_topic.this : k => v.arn }
}

output "topic_names" {
  description = "Map of topic names"
  value       = { for k, v in aws_sns_topic.this : k => v.name }
}
