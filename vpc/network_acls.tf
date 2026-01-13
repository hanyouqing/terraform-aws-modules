# Network ACLs for defense in depth
# Note: Network ACLs are stateless and operate at the subnet level

# Default Network ACL (restrictive)
resource "aws_default_network_acl" "main" {
  count = var.enable_network_acls ? 1 : 0

  default_network_acl_id = aws_vpc.main.default_network_acl_id

  # Deny all ingress by default (explicit deny)
  ingress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    action     = "deny"
  }

  # Allow all egress (can be restricted per subnet)
  egress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-default-nacl"
      Type = "network-acl"
    }
  )

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# Public Subnet Network ACL
resource "aws_network_acl" "public" {
  count = var.enable_network_acls ? 1 : 0

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  # Allow HTTP (80) from internet
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
    action     = "allow"
  }

  # Allow HTTPS (443) from internet
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
    action     = "allow"
  }

  # Allow ephemeral ports for return traffic
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
    action     = "allow"
  }

  # Allow all egress
  egress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-public-nacl"
      Type = "network-acl"
    }
  )
}

# Private Subnet Network ACL
resource "aws_network_acl" "private" {
  count = var.enable_network_acls ? 1 : 0

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Allow all traffic from VPC CIDR
  ingress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }

  # Allow ephemeral ports for return traffic from internet
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
    action     = "allow"
  }

  # Allow all egress
  egress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-nacl"
      Type = "network-acl"
    }
  )
}

# Database Subnet Network ACL (most restrictive)
resource "aws_network_acl" "database" {
  count = var.enable_network_acls ? 1 : 0

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.database[*].id

  # Allow traffic from private subnets only
  ingress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }

  # Allow egress to VPC CIDR only
  egress {
    rule_no    = 100
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
    action     = "allow"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-database-nacl"
      Type = "network-acl"
    }
  )
}
