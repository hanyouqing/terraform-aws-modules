# VPC
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6 && var.ipv6_cidr_block == null ? true : null
  # Note: ipv6_cidr_block requires ipv6_ipam_pool_id in AWS provider 6.28+
  # If ipv6_cidr_block is specified, both must be provided. Use assign_generated_ipv6_cidr_block instead.

  tags = merge(
    local.common_tags,
    {
      Name = local.name
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags that are managed externally
      tags["LastModified"],
    ]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-igw"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = local.public_subnets_map

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = each.value.cidr_block
  availability_zone               = each.value.az
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 ? (
    each.value.ipv6_prefix_provided != null ? each.value.ipv6_prefix_provided : (
      each.value.ipv6_prefix != null && aws_vpc.main.ipv6_cidr_block != null ?
      cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, each.value.ipv6_prefix) :
      null
    )
  ) : null

  tags = merge(
    local.common_tags,
    var.public_subnet_tags,
    {
      Name = each.key
      Type = "public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = local.private_subnets_map

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = each.value.cidr_block
  availability_zone               = each.value.az
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 ? (
    each.value.ipv6_prefix_provided != null ? each.value.ipv6_prefix_provided : (
      each.value.ipv6_prefix != null && aws_vpc.main.ipv6_cidr_block != null ?
      cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, each.value.ipv6_prefix) :
      null
    )
  ) : null

  tags = merge(
    local.common_tags,
    var.private_subnet_tags,
    {
      Name = each.key
      Type = "private"
    }
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  for_each = local.database_subnets_map

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = each.value.cidr_block
  availability_zone               = each.value.az
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 ? (
    each.value.ipv6_prefix_provided != null ? each.value.ipv6_prefix_provided : (
      each.value.ipv6_prefix != null && aws_vpc.main.ipv6_cidr_block != null ?
      cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, each.value.ipv6_prefix) :
      null
    )
  ) : null

  tags = merge(
    local.common_tags,
    var.database_subnet_tags,
    {
      Name = each.key
      Type = "database"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = local.nat_gateways_map

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )

  depends_on = [aws_internet_gateway.main]

  lifecycle {
    precondition {
      condition     = length(local.public_subnets_map) > 0
      error_message = "Public subnets are required when NAT Gateway is enabled."
    }
  }
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  for_each = local.nat_gateways_map

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value.subnet_key].id

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )

  depends_on = [aws_internet_gateway.main]

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = length(local.public_subnets_map) > 0
      error_message = "Public subnets are required when NAT Gateway is enabled."
    }

    precondition {
      condition     = local.single_nat || length(local.public_subnets_map) >= length(local.private_subnets_map)
      error_message = "When using multiple NAT Gateways, the number of public subnets must be at least equal to the number of private subnets."
    }
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  dynamic "route" {
    for_each = var.enable_ipv6 ? [1] : []
    content {
      ipv6_cidr_block = "::/0"
      gateway_id      = aws_internet_gateway.main.id
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-public-rt"
    }
  )
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets_map

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  for_each = local.private_route_tables_map

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[each.value.nat_gateway_key].id
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  for_each = local.private_route_tables_map

  subnet_id      = aws_subnet.private[each.value.subnet_key].id
  route_table_id = aws_route_table.private[each.key].id
}

# Database Route Tables
resource "aws_route_table" "database" {
  for_each = local.database_route_tables_map

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )
}

# Database Route Table Associations
resource "aws_route_table_association" "database" {
  for_each = local.database_route_tables_map

  subnet_id      = aws_subnet.database[each.value.subnet_key].id
  route_table_id = aws_route_table.database[each.key].id
}

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  count = length(local.database_subnets_map) > 0 ? 1 : 0

  name       = "${local.name}-db-subnet-group"
  subnet_ids = [for k, v in aws_subnet.database : v.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-db-subnet-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# VPC Flow Log IAM Role (for CloudWatch Logs)
resource "aws_iam_role" "vpc_flow_log" {
  count = var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${local.name}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-flow-log-role"
    }
  )
}

# VPC Flow Log IAM Role Policy (for CloudWatch Logs)
resource "aws_iam_role_policy" "vpc_flow_log" {
  count = var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${local.name}-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = [
          aws_cloudwatch_log_group.vpc_flow_log[0].arn,
          "${aws_cloudwatch_log_group.vpc_flow_log[0].arn}:*"
        ]
      }
    ]
  })
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  count = var.enable_flow_log && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = "/aws/vpc/flowlogs/${local.name}"
  retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_logs_encryption_enabled ? var.cloudwatch_logs_kms_key_id : null

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-flow-log"
    }
  )

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = var.cloudwatch_logs_encryption_enabled ? var.cloudwatch_logs_kms_key_id != null : true
      error_message = "cloudwatch_logs_kms_key_id is required when cloudwatch_logs_encryption_enabled is true."
    }
  }
}

# VPC Flow Log
resource "aws_flow_log" "main" {
  count = var.enable_flow_log ? 1 : 0

  iam_role_arn         = var.flow_log_destination_type == "cloud-watch-logs" ? aws_iam_role.vpc_flow_log[0].arn : null
  log_destination_type = var.flow_log_destination_type
  log_destination      = var.flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.vpc_flow_log[0].arn : (var.flow_log_destination_type == "s3" ? var.flow_log_destination_arn : null)
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-flow-log"
    }
  )

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = var.flow_log_destination_type != "s3" || var.flow_log_destination_arn != null
      error_message = "flow_log_destination_arn is required when flow_log_destination_type is 's3'."
    }
  }
}
