resource "aws_iam_role" "this" {
  for_each = var.roles

  name                 = coalesce(each.value.name, "${var.project}-${var.environment}-${each.key}")
  path                 = each.value.path
  description          = each.value.description
  assume_role_policy   = each.value.assume_role_policy
  max_session_duration = each.value.max_session_duration
  permissions_boundary = each.value.permissions_boundary

  tags = merge(local.common_tags, each.value.tags, { Name = each.key })
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = {
    for item in flatten([
      for role_key, role in var.roles : [
        for idx, arn in role.managed_policy_arns : {
          key        = "${role_key}-${idx}"
          role_key   = role_key
          policy_arn = arn
        }
      ]
    ]) : item.key => item
  }

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "inline" {
  for_each = {
    for item in flatten([
      for role_key, role in var.roles : [
        for policy_name, policy_json in role.inline_policies : {
          key      = "${role_key}-${policy_name}"
          role_key = role_key
          name     = policy_name
          policy   = policy_json
        }
      ]
    ]) : item.key => item
  }

  name   = each.value.name
  role   = aws_iam_role.this[each.value.role_key].id
  policy = each.value.policy
}

resource "aws_iam_instance_profile" "this" {
  for_each = { for k, v in var.roles : k => v if v.create_instance_profile }

  name = aws_iam_role.this[each.key].name
  role = aws_iam_role.this[each.key].name
  tags = merge(local.common_tags, each.value.tags)
}
