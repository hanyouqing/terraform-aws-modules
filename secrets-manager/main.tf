resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = coalesce(each.value.name, "${var.project}/${var.environment}/${each.key}")
  description             = each.value.description
  kms_key_id              = each.value.kms_key_id
  recovery_window_in_days = each.value.recovery_window_in_days

  tags = merge(local.common_tags, each.value.tags, { Name = each.key })
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = {
    for k, v in var.secrets : k => v
    if v.secret_string != null || v.secret_key_value != null
  }

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.secret_string != null ? each.value.secret_string : jsonencode(each.value.secret_key_value)
}
