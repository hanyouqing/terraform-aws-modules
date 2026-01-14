resource "aws_security_group" "jump" {
  name        = "${local.name}-jump-sg"
  description = "Security group for jump server (bastion host)"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-jump-sg"
      Type = "jump"
    }
  )
}

# Jump Security Group Ingress Rules - Allow SSH from allowlist
resource "aws_security_group_rule" "jump_ingress_ssh_from_allowlist" {
  count = var.public_security_group_allowlist_enabled && length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.jump.id
  prefix_list_ids   = [aws_ec2_managed_prefix_list.allowlist_ipv4[0].id]
  description       = "${local.name}-jump-sg-rule-ingress: Allow SSH (22) from allowlist IPv4 prefix list"
}

# Jump Security Group Egress Rules
resource "aws_security_group_rule" "jump_egress_all" {
  count = var.enable_explicit_egress_rules ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jump.id
  cidr_blocks       = var.security_group_egress_cidr_blocks
  description       = "${local.name}-jump-sg-rule-egress: Allow all outbound traffic"
}

resource "aws_security_group" "public" {
  name        = "${local.name}-public-sg"
  description = "Security group for public subnets"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-public-sg"
      Type = "public"
    }
  )
}

# Public Security Group Allowlist Rules
resource "aws_security_group_rule" "public_ingress_allowlist_ipv4" {
  for_each = var.public_security_group_allowlist_enabled && length(var.allowlist_ipv4_blocks) > 0 && length(aws_ec2_managed_prefix_list.allowlist_ipv4) > 0 ? {
    for port in var.public_security_group_allowed_tcp_ports : port => port
  } : {}

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  security_group_id = aws_security_group.public.id
  prefix_list_ids   = [aws_ec2_managed_prefix_list.allowlist_ipv4[0].id]
  description       = "${local.name}-public-sg-rule-ingress: Allow TCP port ${each.value} from allowlist IPv4 prefix list"
}

# Public Security Group Egress Rules
resource "aws_security_group_rule" "public_egress_all" {
  count = var.enable_explicit_egress_rules ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.public.id
  cidr_blocks       = var.security_group_egress_cidr_blocks
  description       = "${local.name}-public-sg-rule-egress: Allow all outbound traffic"
}

resource "aws_security_group" "private" {
  name        = "${local.name}-private-sg"
  description = "Security group for private subnets"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-sg"
      Type = "private"
    }
  )
}

# Private Security Group Egress Rules
resource "aws_security_group_rule" "private_egress_all" {
  count = var.enable_explicit_egress_rules ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.private.id
  cidr_blocks       = var.security_group_egress_cidr_blocks
  description       = "${local.name}-private-sg-rule-egress: Allow all outbound traffic"
}

resource "aws_security_group_rule" "public_ingress_ssh_from_jump" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.public.id
  source_security_group_id = aws_security_group.jump.id
  description              = "${local.name}-public-sg-rule-ssh: Allow SSH (22) from jump security group"
}

resource "aws_security_group_rule" "private_ingress_ssh_from_jump" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private.id
  source_security_group_id = aws_security_group.jump.id
  description              = "${local.name}-private-sg-rule-ssh: Allow SSH (22) from jump security group"
}

resource "aws_security_group" "database" {
  name        = "${local.name}-database-sg"
  description = "Security group for database subnets"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-database-sg"
      Type = "database"
    }
  )
}

# Database Security Group Ingress Rules
# Allow access from private security group (application tier)
resource "aws_security_group_rule" "database_ingress_from_private" {
  for_each = local.database_security_group_allowed_ports_map

  type                     = "ingress"
  from_port                = each.value
  to_port                  = each.value
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.private.id
  description              = "${local.name}-database-sg-rule-ingress: Allow port ${each.value} (${each.key}) from private security group"
}

# Allow access from specified CIDR blocks
resource "aws_security_group_rule" "database_ingress_from_cidr" {
  for_each = {
    for idx, cidr in var.database_security_group_allowed_cidr_blocks : idx => cidr
  }

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.database.id
  cidr_blocks       = [each.value]
  description       = "${local.name}-database-sg-rule-ingress: Allow MySQL (3306) from ${each.value}"
}

# Database Security Group Egress Rules
resource "aws_security_group_rule" "database_egress_all" {
  count = var.enable_explicit_egress_rules ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.database.id
  cidr_blocks       = var.security_group_egress_cidr_blocks
  description       = "${local.name}-database-sg-rule-egress: Allow all outbound traffic"
}

# Allow HTTPS (443) from private security group to VPC endpoints (via VPC CIDR)
resource "aws_security_group_rule" "private_egress_to_vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.private.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "${local.name}-private-sg-rule-egress: Allow HTTPS (443) to VPC endpoints (VPC CIDR)"
}

# Allow HTTPS (443) from public security group to VPC endpoints (via VPC CIDR)
resource "aws_security_group_rule" "public_egress_to_vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.public.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "${local.name}-public-sg-rule-egress: Allow HTTPS (443) to VPC endpoints (VPC CIDR)"
}

# Allow HTTPS (443) from database security group to VPC endpoints (via VPC CIDR)
resource "aws_security_group_rule" "database_egress_to_vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.database.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "${local.name}-database-sg-rule-egress: Allow HTTPS (443) to VPC endpoints (VPC CIDR)"
}

# Allow HTTPS (443) from jump security group to VPC endpoints (via VPC CIDR)
resource "aws_security_group_rule" "jump_egress_to_vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.jump.id
  cidr_blocks       = [var.vpc_cidr]
  description       = "${local.name}-jump-sg-rule-egress: Allow HTTPS (443) to VPC endpoints (VPC CIDR)"
}
