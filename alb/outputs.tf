output "lb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "lb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "lb_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Map of target group ARNs"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}
