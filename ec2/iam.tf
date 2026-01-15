# ==============================================================================
# IAM Role and Instance Profile for EC2 Instances
# ==============================================================================
# This IAM role allows EC2 instances to:
# - Access EC2 instances (for SSH connections) - always enabled when iam_instance_profile_enabled = true
# - Access Systems Manager Session Manager (when enable_ssm_session_manager = true)
# - Access ElastiCache (for Redis connections) - when enable_elasticache = true
# - Access RDS databases (when enable_rds = true)
# - Access ECR repositories (when enable_ecr = true)
# - Access EKS clusters (when enable_eks = true)
# - Access ECS clusters (when enable_ecs = true)
# ==============================================================================

resource "aws_iam_role" "main" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? 1 : 0

  name = var.iam_role_name != null ? var.iam_role_name : "${local.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-role"
    }
  )
}

# Policy for EC2 access (for SSH connections)
resource "aws_iam_role_policy" "main_ec2_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? 1 : 0

  name = "${local.name}-ec2-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy for RDS access (for database connections and Secrets Manager access)
resource "aws_iam_role_policy" "main_rds_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_rds ? 1 : 0

  name = "${local.name}-rds-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterEndpoints",
          "rds:DescribeDBClusterParameterGroups",
          "rds:DescribeDBParameters",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*rds*master*password*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Policy for ElastiCache access (for Redis connections)
resource "aws_iam_role_policy" "main_elasticache_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_elasticache ? 1 : 0

  name = "${local.name}-elasticache-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:DescribeReplicationGroups",
          "elasticache:DescribeCacheNodes",
          "elasticache:DescribeCacheParameterGroups",
          "elasticache:DescribeCacheParameters",
          "elasticache:DescribeCacheSubnetGroups",
          "elasticache:DescribeEvents",
          "elasticache:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy for ECR access (for Docker image pull/push operations)
resource "aws_iam_role_policy" "main_ecr_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_ecr ? 1 : 0

  name = "${local.name}-ecr-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:UntagResource"
        ]
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetRepositoryPolicy",
          "ecr:CreateRepository",
          "ecr:DeleteRepository"
        ]
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })
}

# Policy for EKS access (for kubectl configuration and cluster access)
resource "aws_iam_role_policy" "main_eks_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_eks ? 1 : 0

  name = "${local.name}-eks-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeAddon",
          "eks:ListAddons",
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeAccessEntry",
          "eks:ListAccessEntries",
          "eks:DescribeAccessPolicy",
          "eks:ListAccessPolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy for ECS access (for cluster, service, and task management)
resource "aws_iam_role_policy" "main_ecs_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_ecs ? 1 : 0

  name = "${local.name}-ecs-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
          "ecs:ListClusters",
          "ecs:DescribeServices",
          "ecs:ListServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeContainerInstances",
          "ecs:ListContainerInstances",
          "ecs:DescribeTaskSets",
          "ecs:ListTaskSets",
          "ecs:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:StartTask"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ecs:cluster" = "*"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:CreateService",
          "ecs:DeleteService"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ExecuteCommand"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ecs:cluster" = "*"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Additional IAM role policies
resource "aws_iam_role_policy" "main_custom" {
  for_each = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? var.iam_role_policies : {}

  name   = each.key
  role   = aws_iam_role.main[0].id
  policy = each.value
}

# Attach managed policies to IAM role
resource "aws_iam_role_policy_attachment" "main_managed" {
  for_each = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? toset(concat(var.iam_role_policy_arns, var.ec2_external_policy_arns)) : toset([])

  role       = aws_iam_role.main[0].name
  policy_arn = each.value
}

# Attach SSM Session Manager policy (AmazonSSMManagedInstanceCore)
resource "aws_iam_role_policy_attachment" "main_ssm" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_ssm_session_manager ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile
resource "aws_iam_instance_profile" "main" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? 1 : 0

  name = "${local.name}-profile"
  role = aws_iam_role.main[0].name

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-profile"
    }
  )
}
