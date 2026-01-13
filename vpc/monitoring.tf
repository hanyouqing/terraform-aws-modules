# CloudWatch Alarms for NAT Gateway
resource "aws_cloudwatch_metric_alarm" "nat_gateway_bandwidth" {
  for_each = var.enable_cloudwatch_alarms && var.enable_nat_gateway ? {
    for idx, nat in aws_nat_gateway.main : nat.id => nat
  } : {}

  alarm_name          = "${local.name}-nat-gateway-bandwidth-${substr(each.value.id, -8, 8)}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.nat_gateway_bandwidth_threshold
  alarm_description   = "This metric monitors NAT Gateway bandwidth usage"
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = each.value.id
  }

  alarm_actions = var.cloudwatch_alarm_sns_topic_arn != null ? [var.cloudwatch_alarm_sns_topic_arn] : []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-nat-gateway-bandwidth-alarm"
      Type = "cloudwatch-alarm"
    }
  )

  lifecycle {
    precondition {
      condition     = var.cloudwatch_alarm_sns_topic_arn != null
      error_message = "cloudwatch_alarm_sns_topic_arn is required when enable_cloudwatch_alarms is true."
    }
  }
}

# CloudWatch Alarm for VPC Flow Logs
resource "aws_cloudwatch_metric_alarm" "vpc_flow_logs" {
  count = var.enable_cloudwatch_alarms && var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  alarm_name          = "${local.name}-vpc-flow-logs-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "This metric monitors VPC Flow Logs errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.vpc_flow_log[0].name
  }

  alarm_actions = var.cloudwatch_alarm_sns_topic_arn != null ? [var.cloudwatch_alarm_sns_topic_arn] : []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-flow-logs-alarm"
      Type = "cloudwatch-alarm"
    }
  )
}

# Cost Anomaly Detection Monitor
resource "aws_ce_anomaly_monitor" "main" {
  count = var.enable_cost_anomaly_detection ? 1 : 0

  name         = var.cost_anomaly_detection_monitor_name != null ? var.cost_anomaly_detection_monitor_name : "${local.name}-cost-anomaly-monitor"
  monitor_type = "DIMENSIONAL"
  monitor_specification = jsonencode({
    Dimension    = "SERVICE"
    MatchOptions = ["EQUALS"]
    Values = [
      "Amazon Virtual Private Cloud",
      "Amazon Elastic Compute Cloud - Compute",
      "Amazon Elastic Compute Cloud - Other"
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-cost-anomaly-monitor"
      Type = "cost-anomaly-monitor"
    }
  )
}

# Cost Anomaly Detection Subscription
resource "aws_ce_anomaly_subscription" "main" {
  count = var.enable_cost_anomaly_detection && var.cloudwatch_alarm_sns_topic_arn != null ? 1 : 0

  name             = "${local.name}-cost-anomaly-subscription"
  monitor_arn_list = [aws_ce_anomaly_monitor.main[0].arn]
  frequency        = "IMMEDIATE"

  subscriber {
    type    = "SNS"
    address = var.cloudwatch_alarm_sns_topic_arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.cost_anomaly_detection_threshold)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-cost-anomaly-subscription"
      Type = "cost-anomaly-subscription"
    }
  )

  lifecycle {
    precondition {
      condition     = var.cloudwatch_alarm_sns_topic_arn != null
      error_message = "cloudwatch_alarm_sns_topic_arn is required when enable_cost_anomaly_detection is true."
    }
  }
}
