resource "aws_ec2_managed_prefix_list" "allowlist_ipv4" {
  count          = length(var.allowlist_ipv4_blocks) > 0 ? 1 : 0
  name           = "${local.name}-allowlist-ipv4"
  address_family = "IPv4"
  max_entries    = min(length(var.allowlist_ipv4_blocks) + 2, 100)

  dynamic "entry" {
    for_each = var.allowlist_ipv4_blocks
    content {
      cidr        = entry.value.cidr
      description = entry.value.description
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-allowlist-ipv4"
      Type = "allowlist"
    }
  )
}

resource "aws_ec2_managed_prefix_list" "allowlist_ipv6" {
  count          = length(var.allowlist_ipv6_blocks) > 0 ? 1 : 0
  name           = "${local.name}-allowlist-ipv6"
  address_family = "IPv6"
  max_entries    = min(length(var.allowlist_ipv6_blocks) + 2, 100)

  dynamic "entry" {
    for_each = var.allowlist_ipv6_blocks
    content {
      cidr        = entry.value.cidr
      description = entry.value.description
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-allowlist-ipv6"
      Type = "allowlist"
    }
  )
}
