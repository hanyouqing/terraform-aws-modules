# ==============================================================================
# CloudWatch Logs and Metrics Configuration
# ==============================================================================

# CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "main" {
  count = var.cloudwatch_logs_enabled ? 1 : 0

  name              = var.cloudwatch_logs_group_name != null ? var.cloudwatch_logs_group_name : "${local.name}-logs"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = var.cloudwatch_logs_group_name != null ? var.cloudwatch_logs_group_name : "${local.name}-logs"
      Type = "cloudwatch-logs"
    }
  )
}

# CloudWatch Logs Stream (one per instance)
resource "aws_cloudwatch_log_stream" "main" {
  for_each = var.cloudwatch_logs_enabled ? local.instances : {}

  name           = each.value.hostname
  log_group_name = aws_cloudwatch_log_group.main[0].name
}

# IAM policy for CloudWatch Logs
resource "aws_iam_role_policy" "main_cloudwatch_logs" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.cloudwatch_logs_enabled ? 1 : 0

  name = "${local.name}-cloudwatch-logs-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.main[0].arn}:*"
      }
    ]
  })
}

# IAM policy for CloudWatch Metrics (when CloudWatch agent is enabled)
resource "aws_iam_role_policy" "main_cloudwatch_metrics" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.cloudwatch_metrics_enabled ? 1 : 0

  name = "${local.name}-cloudwatch-metrics-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}
