locals {
  name = "${var.project}-${var.environment}"

  # Caller identity ARN
  # ARN format examples:
  #   - arn:aws:iam::123456789012:user/username
  #   - arn:aws:sts::123456789012:assumed-role/role-name/session-name
  #   - arn:aws:sts::123456789012:assumed-role/role-name/terraform-session
  caller_user_arn = data.aws_caller_identity.current.arn

  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Code        = var.code
      Owner       = var.owner
    },
    var.tags
  )

  single_nat = var.environment != "production" ? true : var.single_nat_gateway

  # Validate subnet counts match availability zones
  public_subnet_count   = length(var.public_subnets)
  private_subnet_count  = length(var.private_subnets)
  database_subnet_count = length(var.database_subnets)
  az_count              = length(var.availability_zones)

  # Automatic CIDR calculation
  calculated_public_subnets = var.enable_auto_cidr ? [
    for i in range(length(var.availability_zones)) : cidrsubnet(
      var.vpc_cidr,
      var.public_subnet_newbits,
      var.public_subnet_offset + i
    )
  ] : var.public_subnets

  calculated_private_subnets = var.enable_auto_cidr ? [
    for i in range(length(var.availability_zones)) : cidrsubnet(
      var.vpc_cidr,
      var.private_subnet_newbits,
      var.private_subnet_offset + i
    )
  ] : var.private_subnets

  calculated_database_subnets = var.enable_auto_cidr ? [
    for i in range(length(var.availability_zones)) : cidrsubnet(
      var.vpc_cidr,
      var.database_subnet_newbits,
      var.database_subnet_offset + i
    )
  ] : var.database_subnets

  # Use calculated or provided subnets
  public_subnets   = local.calculated_public_subnets
  private_subnets  = local.calculated_private_subnets
  database_subnets = local.calculated_database_subnets

  # Maps for for_each (using resource names as keys)
  # Public subnets map: key is the subnet name (e.g., "vpc-basic-development-public-a")
  public_subnets_map = {
    for idx, az in var.availability_zones : "${local.name}-public-${substr(az, -1, 1)}" => {
      cidr_block           = local.public_subnets[idx]
      az                   = az
      az_suffix            = substr(az, -1, 1)
      ipv6_prefix          = length(local.calculated_public_subnet_ipv6_prefixes) > idx ? local.calculated_public_subnet_ipv6_prefixes[idx] : null
      ipv6_prefix_provided = length(var.public_subnet_ipv6_prefixes) > idx && var.public_subnet_ipv6_prefixes[idx] != "" ? var.public_subnet_ipv6_prefixes[idx] : null
    }
  }

  # Private subnets map: key is the subnet name (e.g., "vpc-basic-development-private-a")
  private_subnets_map = {
    for idx, az in var.availability_zones : "${local.name}-private-${substr(az, -1, 1)}" => {
      cidr_block           = local.private_subnets[idx]
      az                   = az
      az_suffix            = substr(az, -1, 1)
      ipv6_prefix          = length(local.calculated_private_subnet_ipv6_prefixes) > idx ? local.calculated_private_subnet_ipv6_prefixes[idx] : null
      ipv6_prefix_provided = length(var.private_subnet_ipv6_prefixes) > idx && var.private_subnet_ipv6_prefixes[idx] != "" ? var.private_subnet_ipv6_prefixes[idx] : null
    }
  }

  # Database subnets map: key is the subnet name (e.g., "vpc-basic-development-database-a")
  database_subnets_map = length(local.database_subnets) > 0 ? {
    for idx, az in var.availability_zones : "${local.name}-database-${substr(az, -1, 1)}" => {
      cidr_block           = local.database_subnets[idx]
      az                   = az
      az_suffix            = substr(az, -1, 1)
      ipv6_prefix          = length(local.calculated_database_subnet_ipv6_prefixes) > idx ? local.calculated_database_subnet_ipv6_prefixes[idx] : null
      ipv6_prefix_provided = length(var.database_subnet_ipv6_prefixes) > idx && var.database_subnet_ipv6_prefixes[idx] != "" ? var.database_subnet_ipv6_prefixes[idx] : null
    }
  } : {}

  # NAT Gateway map: key is the NAT gateway name (e.g., "vpc-basic-development-nat-a")
  nat_gateways_map = var.enable_nat_gateway ? (
    local.single_nat ? {
      "${local.name}-nat-${substr(var.availability_zones[0], -1, 1)}" = {
        index      = 0
        subnet_key = "${local.name}-public-${substr(var.availability_zones[0], -1, 1)}"
        az_suffix  = substr(var.availability_zones[0], -1, 1)
      }
      } : {
      for idx, az in var.availability_zones : "${local.name}-nat-${substr(az, -1, 1)}" => {
        index      = idx
        subnet_key = "${local.name}-public-${substr(az, -1, 1)}"
        az_suffix  = substr(az, -1, 1)
      }
    }
  ) : {}

  # Private route tables map: key is the route table name (e.g., "vpc-basic-development-private-rt-a")
  private_route_tables_map = {
    for idx, az in var.availability_zones : "${local.name}-private-rt-${substr(az, -1, 1)}" => {
      az              = az
      az_suffix       = substr(az, -1, 1)
      subnet_key      = "${local.name}-private-${substr(az, -1, 1)}"
      nat_gateway_key = local.single_nat ? "${local.name}-nat-${substr(var.availability_zones[0], -1, 1)}" : "${local.name}-nat-${substr(az, -1, 1)}"
    }
  }

  # Database route tables map: key is the route table name (e.g., "vpc-basic-development-database-rt-a")
  database_route_tables_map = length(local.database_subnets) > 0 ? {
    for idx, az in var.availability_zones : "${local.name}-database-rt-${substr(az, -1, 1)}" => {
      az         = az
      az_suffix  = substr(az, -1, 1)
      subnet_key = "${local.name}-database-${substr(az, -1, 1)}"
    }
  } : {}

  # IPv6 prefix calculation
  calculated_public_subnet_ipv6_prefixes = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) == 0 ? [
    for i in range(length(var.availability_zones)) : i
  ] : var.public_subnet_ipv6_prefixes

  calculated_private_subnet_ipv6_prefixes = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) == 0 ? [
    for i in range(length(var.availability_zones)) : i + 10
  ] : var.private_subnet_ipv6_prefixes

  calculated_database_subnet_ipv6_prefixes = var.enable_ipv6 && length(var.database_subnet_ipv6_prefixes) == 0 ? [
    for i in range(length(var.availability_zones)) : i + 20
  ] : var.database_subnet_ipv6_prefixes

  # VPC Peering connection keys for route mapping
  vpc_peering_connection_keys = var.enable_vpc_peering ? {
    for idx, peer in var.vpc_peering_connections : "${peer.peer_vpc_id}-${idx}" => peer
  } : {}

  # Interface endpoints configuration
  interface_endpoints = {
    ecr_dkr = {
      enabled      = var.enable_vpc_endpoints && var.enable_ecr_dkr_endpoint
      service_name = "ecr.dkr"
      name         = "ecr-dkr"
      private_dns  = true
    }
    ecr_api = {
      enabled      = var.enable_vpc_endpoints && var.enable_ecr_api_endpoint
      service_name = "ecr.api"
      name         = "ecr-api"
      private_dns  = true
    }
    eks = {
      enabled      = var.enable_vpc_endpoints && var.enable_eks_endpoint
      service_name = "eks"
      name         = "eks"
      private_dns  = true
    }
    cloudwatch_logs = {
      enabled      = var.enable_vpc_endpoints && var.enable_cloudwatch_logs_endpoint
      service_name = "logs"
      name         = "cloudwatch-logs"
      private_dns  = true
    }
    secretsmanager = {
      enabled      = var.enable_vpc_endpoints && var.enable_secretsmanager_endpoint
      service_name = "secretsmanager"
      name         = "secretsmanager"
      private_dns  = true
    }
    ssm = {
      enabled      = var.enable_vpc_endpoints && var.enable_ssm_endpoint
      service_name = "ssm"
      name         = "ssm"
      private_dns  = true
    }
    ssmmessages = {
      enabled      = var.enable_vpc_endpoints && var.enable_ssmmessages_endpoint
      service_name = "ssmmessages"
      name         = "ssmmessages"
      private_dns  = true
    }
    ec2messages = {
      enabled      = var.enable_vpc_endpoints && var.enable_ec2messages_endpoint
      service_name = "ec2messages"
      name         = "ec2messages"
      private_dns  = true
    }
    sts = {
      enabled      = var.enable_vpc_endpoints && var.enable_sts_endpoint
      service_name = "sts"
      name         = "sts"
      private_dns  = true
    }
  }

  # Gateway endpoints configuration
  gateway_endpoints = {
    s3 = {
      enabled      = var.enable_vpc_endpoints && var.enable_s3_endpoint
      service_name = "s3"
      name         = "s3"
    }
    dynamodb = {
      enabled      = var.enable_vpc_endpoints && var.enable_dynamodb_endpoint
      service_name = "dynamodb"
      name         = "dynamodb"
    }
  }

  # Database port name mapping (for readable security group rule keys)
  database_port_names = {
    1433  = "sqlserver"
    3306  = "mysql"
    5432  = "postgresql"
    6379  = "redis"
    27017 = "mongodb"
    1521  = "oracle"
    5984  = "couchdb"
    9200  = "elasticsearch"
    9042  = "cassandra"
  }

  # Database security group allowed ports map (for for_each)
  # Uses port name if available, otherwise uses port number as string
  database_security_group_allowed_ports_map = {
    for port in var.database_security_group_allowed_ports : (
      contains(keys(local.database_port_names), port) ? local.database_port_names[port] : tostring(port)
    ) => port
  }

  # Security Group Rule Counts (for validation)
  # AWS limits security groups to 60 rules per direction (ingress/egress)
  public_sg_ingress_count = (
    1 + # SSH from jump
    (var.public_security_group_allowlist_enabled && length(var.allowlist_ipv4_blocks) > 0 ? length(var.public_security_group_allowed_tcp_ports) : 0)
  )

  public_sg_egress_count = (
    (var.enable_explicit_egress_rules ? 1 : 0) +
    (var.enable_vpc_endpoints ? 1 : 0)
  )

  private_sg_ingress_count = 1 # SSH from jump

  private_sg_egress_count = (
    (var.enable_explicit_egress_rules ? 1 : 0) +
    (var.enable_vpc_endpoints ? 1 : 0)
  )

  database_sg_ingress_count = (
    length(local.database_security_group_allowed_ports_map) +
    length(var.database_security_group_allowed_cidr_blocks)
  )

  database_sg_egress_count = (
    (var.enable_explicit_egress_rules ? 1 : 0) +
    (var.enable_vpc_endpoints ? 1 : 0)
  )

  jump_sg_ingress_count = var.public_security_group_allowlist_enabled && length(var.allowlist_ipv4_blocks) > 0 ? 1 : 0

  jump_sg_egress_count = (
    (var.enable_explicit_egress_rules ? 1 : 0) +
    (var.enable_vpc_endpoints ? 1 : 0)
  )

  vpc_endpoints_sg_ingress_count = var.enable_vpc_endpoints ? 4 : 0 # private, public, database, jump
  vpc_endpoints_sg_egress_count  = var.enable_vpc_endpoints ? 1 : 0

  # VPC Endpoint Policies (service-specific)
  vpc_endpoint_policies = {
    ecr_dkr = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    ecr_api = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:DescribeRepositories",
            "ecr:DescribeImages",
            "ecr:ListImages"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    eks = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "eks:DescribeCluster",
            "eks:ListClusters"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    cloudwatch_logs = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    secretsmanager = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    ssm = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    ssmmessages = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "ssm:SendCommand",
            "ssm:GetCommandInvocation"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    ec2messages = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "ec2messages:AcknowledgeMessage",
            "ec2messages:SendMessage"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
    sts = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "sts:AssumeRole",
            "sts:GetCallerIdentity"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceVpc" = aws_vpc.main.id
            }
          }
        }
      ]
    })
  }
}

