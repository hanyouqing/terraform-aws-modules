# Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  subnet_ids                                      = aws_subnet.private[*].id
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.main.id
  dns_support                                     = var.transit_gateway_dns_support ? "enable" : "disable"
  ipv6_support                                    = var.transit_gateway_ipv6_support ? "enable" : "disable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-tgw-attachment"
      Type = "transit-gateway-attachment"
    }
  )

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = var.transit_gateway_id != null
      error_message = "transit_gateway_id is required when enable_transit_gateway is true."
    }
  }
}

# Transit Gateway Routes
resource "aws_route" "transit_gateway" {
  for_each = var.enable_transit_gateway ? var.transit_gateway_routes : {}

  route_table_id         = each.key
  destination_cidr_block = each.value
  transit_gateway_id     = var.transit_gateway_id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.main]
}
