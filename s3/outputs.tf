output "bucket_ids" {
  description = "Map of bucket keys to bucket IDs"
  value       = { for k, b in aws_s3_bucket.this : k => b.id }
}

output "bucket_arns" {
  description = "Map of bucket keys to bucket ARNs"
  value       = { for k, b in aws_s3_bucket.this : k => b.arn }
}

output "bucket_domain_names" {
  description = "Map of bucket keys to domain names"
  value       = { for k, b in aws_s3_bucket.this : k => b.bucket_domain_name }
}
