locals {
  name = "${var.project}-${var.environment}"

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
    length(var.database_security_group_allowed_ports) +
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

