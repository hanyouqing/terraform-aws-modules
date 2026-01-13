resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name        = "${local.name}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-endpoints-sg"
      Type = "vpc-endpoints"
    }
  )
}

resource "aws_security_group_rule" "vpc_endpoints_egress_all" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_endpoints[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.name}-vpc-endpoints-sg-rule-egress: Allow all outbound traffic"
}

# Allow HTTPS (443) from private security group to VPC endpoints
resource "aws_security_group_rule" "vpc_endpoints_ingress_from_private" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints[0].id
  source_security_group_id = aws_security_group.private.id
  description              = "${local.name}-vpc-endpoints-sg-rule-ingress: Allow HTTPS (443) from private security group"
}

# Allow HTTPS (443) from public security group to VPC endpoints
resource "aws_security_group_rule" "vpc_endpoints_ingress_from_public" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints[0].id
  source_security_group_id = aws_security_group.public.id
  description              = "${local.name}-vpc-endpoints-sg-rule-ingress: Allow HTTPS (443) from public security group"
}

# Allow HTTPS (443) from database security group to VPC endpoints
resource "aws_security_group_rule" "vpc_endpoints_ingress_from_database" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints[0].id
  source_security_group_id = aws_security_group.database.id
  description              = "${local.name}-vpc-endpoints-sg-rule-ingress: Allow HTTPS (443) from database security group"
}

# Allow HTTPS (443) from jump security group to VPC endpoints
resource "aws_security_group_rule" "vpc_endpoints_ingress_from_jump" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints[0].id
  source_security_group_id = aws_security_group.jump.id
  description              = "${local.name}-vpc-endpoints-sg-rule-ingress: Allow HTTPS (443) from jump security group"
}

# Interface endpoints (ECR, EKS, CloudWatch Logs, Secrets Manager)
resource "aws_vpc_endpoint" "interface" {
  for_each = {
    for k, v in local.interface_endpoints : k => v
    if v.enabled
  }

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.${each.value.service_name}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
  private_dns_enabled = each.value.private_dns
  policy              = var.vpc_endpoint_policy_enabled && contains(keys(local.vpc_endpoint_policies), each.key) ? local.vpc_endpoint_policies[each.key] : null

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-${each.value.name}-endpoint"
      Type = "vpc-endpoint"
    }
  )
}

# Gateway endpoints (S3)
resource "aws_vpc_endpoint" "gateway" {
  for_each = {
    for k, v in local.gateway_endpoints : k => v
    if v.enabled
  }

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.${each.value.service_name}"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    aws_route_table.private[*].id,
    aws_route_table.database[*].id
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-${each.value.name}-endpoint"
      Type = "vpc-endpoint"
    }
  )
}
