# VPC Peering Connections
resource "aws_vpc_peering_connection" "main" {
  for_each = var.enable_vpc_peering ? {
    for idx, peer in var.vpc_peering_connections : "${peer.peer_vpc_id}-${idx}" => peer
  } : {}

  vpc_id        = aws_vpc.main.id
  peer_vpc_id   = each.value.peer_vpc_id
  peer_region   = each.value.peer_region
  peer_owner_id = each.value.peer_owner_id
  auto_accept   = each.value.auto_accept

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = "${local.name}-peering-${substr(each.value.peer_vpc_id, -8, 8)}"
      Type = "vpc-peering"
    }
  )
}

# VPC Peering Routes
resource "aws_route" "peering" {
  for_each = var.enable_vpc_peering ? var.vpc_peering_routes : {}

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[each.value.peering_connection_key].id

  lifecycle {
    precondition {
      condition     = contains(keys(aws_vpc_peering_connection.main), each.value.peering_connection_key)
      error_message = "peering_connection_key '${each.value.peering_connection_key}' does not exist in vpc_peering_connections. Valid keys are: ${join(", ", keys(aws_vpc_peering_connection.main))}."
    }
  }
}

# VPC Peering Connection Accepter (for cross-account or cross-region)
resource "aws_vpc_peering_connection_accepter" "main" {
  for_each = var.enable_vpc_peering ? {
    for k, v in aws_vpc_peering_connection.main : k => v
    if !v.auto_accept
  } : {}

  vpc_peering_connection_id = each.value.id
  auto_accept               = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-peering-accepter-${substr(each.value.peer_vpc_id, -8, 8)}"
      Type = "vpc-peering-accepter"
    }
  )
}
