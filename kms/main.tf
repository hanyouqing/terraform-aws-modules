data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_kms_key" "this" {
  for_each = var.keys

  description             = each.value.description
  deletion_window_in_days = each.value.deletion_window_in_days
  enable_key_rotation     = each.value.enable_key_rotation
  multi_region            = each.value.multi_region
  policy                  = each.value.policy

  tags = merge(local.common_tags, each.value.tags, { Name = each.key })
}

resource "aws_kms_alias" "this" {
  for_each = { for k, v in var.keys : k => v if v.alias != null }

  name          = startswith(each.value.alias, "alias/") ? each.value.alias : "alias/${each.value.alias}"
  target_key_id = aws_kms_key.this[each.key].key_id
}
