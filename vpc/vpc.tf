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
  count = length(local.public_subnets)

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = local.public_subnets[count.index]
  availability_zone               = var.availability_zones[count.index]
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 ? (
    length(var.public_subnet_ipv6_prefixes) > count.index && var.public_subnet_ipv6_prefixes[count.index] != "" ?
    var.public_subnet_ipv6_prefixes[count.index] : (
      length(local.calculated_public_subnet_ipv6_prefixes) > count.index && aws_vpc.main.ipv6_cidr_block != null ?
      cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, local.calculated_public_subnet_ipv6_prefixes[count.index]) :
      null
    )
  ) : null

  tags = merge(
    local.common_tags,
    var.public_subnet_tags,
    {
      Name = "${local.name}-public-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = local.private_subnets[count.index]
  availability_zone               = var.availability_zones[count.index]
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 ? (
    length(var.private_subnet_ipv6_prefixes) > count.index && var.private_subnet_ipv6_prefixes[count.index] != "" ?
    var.private_subnet_ipv6_prefixes[count.index] : (
      length(local.calculated_private_subnet_ipv6_prefixes) > count.index && aws_vpc.main.ipv6_cidr_block != null ?
      cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, local.calculated_private_subnet_ipv6_prefixes[count.index]) :
      null
    )
  ) : null

  tags = merge(
    local.common_tags,
    var.private_subnet_tags,
    {
      Name = "${local.name}-private-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "private"
    }
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(local.database_subnets)

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = local.database_subnets[count.index]
  availability_zone               = var.availability_zones[count.index]
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 ? (
    length(var.database_subnet_ipv6_prefixes) > count.index && var.database_subnet_ipv6_prefixes[count.index] != "" ?
    var.database_subnet_ipv6_prefixes[count.index] : (
      length(local.calculated_database_subnet_ipv6_prefixes) > count.index && aws_vpc.main.ipv6_cidr_block != null ?
      cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, local.calculated_database_subnet_ipv6_prefixes[count.index]) :
      null
    )
  ) : null

  tags = merge(
    local.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.name}-database-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "database"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (local.single_nat ? 1 : length(local.private_subnets)) : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]

  lifecycle {
    precondition {
      condition     = length(local.public_subnets) > 0
      error_message = "Public subnets are required when NAT Gateway is enabled."
    }
  }
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (local.single_nat ? 1 : length(local.private_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[local.single_nat ? 0 : count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = length(local.public_subnets) > 0
      error_message = "Public subnets are required when NAT Gateway is enabled."
    }

    precondition {
      condition     = local.single_nat || length(local.public_subnets) >= length(local.private_subnets)
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
  count = length(local.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = length(local.private_subnets)

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[local.single_nat ? 0 : count.index].id
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-rt-${substr(var.availability_zones[count.index], -1, 1)}"
    }
  )
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = length(local.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Database Route Tables
resource "aws_route_table" "database" {
  count = length(local.database_subnets)

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-database-rt-${substr(var.availability_zones[count.index], -1, 1)}"
    }
  )
}

# Database Route Table Associations
resource "aws_route_table_association" "database" {
  count = length(local.database_subnets)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  count = length(local.database_subnets) > 0 ? 1 : 0

  name       = "${local.name}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

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
