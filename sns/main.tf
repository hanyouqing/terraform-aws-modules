resource "aws_sns_topic" "this" {
  for_each = var.topics

  name                        = coalesce(each.value.name, "${var.project}-${var.environment}-${each.key}${each.value.fifo_topic ? ".fifo" : ""}")
  display_name                = each.value.display_name
  kms_master_key_id           = each.value.kms_master_key_id
  fifo_topic                  = each.value.fifo_topic
  content_based_deduplication = each.value.content_based_deduplication

  tags = merge(local.common_tags, each.value.tags, { Name = each.key })
}

resource "aws_sns_topic_subscription" "this" {
  for_each = {
    for item in flatten([
      for topic_key, topic in var.topics : [
        for idx, sub in topic.subscriptions : {
          key       = "${topic_key}-${idx}"
          topic_key = topic_key
          protocol  = sub.protocol
          endpoint  = sub.endpoint
        }
      ]
    ]) : item.key => item
  }

  topic_arn = aws_sns_topic.this[each.value.topic_key].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
