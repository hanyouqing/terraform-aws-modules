resource "aws_organizations_account" "accounts" {
  for_each = local.accounts_map

  name                       = each.value.name
  email                      = each.value.email
  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  role_name                  = each.value.role_name
  close_on_deletion          = each.value.close_on_deletion

  tags = merge(
    local.default_tags,
    {
      Name = each.value.name
    },
    each.value.tags
  )

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_organizational_unit" "ous" {
  for_each = local.organizational_units_map

  name      = each.value.name
  parent_id = each.value.parent_id != null ? each.value.parent_id : local.root_id

  tags = merge(
    local.default_tags,
    {
      Name = each.value.name
    },
    each.value.tags
  )
}

resource "aws_organizations_policy" "scps" {
  for_each = local.service_control_policies_map

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  content     = each.value.content

  tags = merge(
    local.default_tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_organizations_policy_attachment" "scp_attachments" {
  for_each = {
    for pair in flatten([
      for scp in var.service_control_policies : [
        for target in length(scp.targets) > 0 ? scp.targets : [local.root_id] : {
          key       = "${scp.name}-${target}"
          policy_id = aws_organizations_policy.scps[scp.name].id
          target_id = target
        }
      ]
    ]) : pair.key => pair
  }

  policy_id = each.value.policy_id
  target_id = each.value.target_id
}

