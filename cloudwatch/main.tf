resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = coalesce(each.value.name, "/${var.project}/${var.environment}/${each.key}")
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id

  tags = merge(local.common_tags, each.value.tags, { Name = each.key })
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_alarms

  alarm_name          = coalesce(each.value.alarm_name, "${var.project}-${var.environment}-${each.key}")
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  alarm_actions       = each.value.alarm_actions
  ok_actions          = each.value.ok_actions
  treat_missing_data  = each.value.treat_missing_data
  dimensions          = each.value.dimensions

  tags = merge(local.common_tags, each.value.tags)
}
