# ==============================================================================
# IAM Role and Instance Profile for EC2 Instances (least privilege)
# ==============================================================================
# EC2/RDS/ElastiCache "Describe*" APIs generally require Resource="*" (AWS IAM
# limitation). Mutating and data-plane actions are scoped to account/region ARNs
# or caller-provided resource ARN lists.
# ==============================================================================

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  secrets_arns = length(var.iam_secrets_arns) > 0 ? var.iam_secrets_arns : [
    "arn:${local.partition}:secretsmanager:${var.region}:${local.account_id}:secret:${var.project}-${var.environment}-*",
    "arn:${local.partition}:secretsmanager:${var.region}:${local.account_id}:secret:rds*",
  ]

  ecr_repository_arns = length(var.iam_ecr_repository_arns) > 0 ? var.iam_ecr_repository_arns : [
    "arn:${local.partition}:ecr:${var.region}:${local.account_id}:repository/${var.project}-*",
  ]

  eks_cluster_arns = length(var.iam_eks_cluster_arns) > 0 ? var.iam_eks_cluster_arns : [
    "arn:${local.partition}:eks:${var.region}:${local.account_id}:cluster/${var.project}-*",
  ]

  ecs_cluster_arns = length(var.iam_ecs_cluster_arns) > 0 ? var.iam_ecs_cluster_arns : [
    "arn:${local.partition}:ecs:${var.region}:${local.account_id}:cluster/${var.project}-*",
  ]

  ecs_service_arns = length(var.iam_ecs_service_arns) > 0 ? var.iam_ecs_service_arns : [
    "arn:${local.partition}:ecs:${var.region}:${local.account_id}:service/${var.project}-*/*",
  ]

  ecs_task_definition_arns = length(var.iam_ecs_task_definition_arns) > 0 ? var.iam_ecs_task_definition_arns : [
    "arn:${local.partition}:ecs:${var.region}:${local.account_id}:task-definition/${var.project}-*:*",
  ]

  kms_key_arns = length(var.iam_kms_key_arns) > 0 ? var.iam_kms_key_arns : [
    "arn:${local.partition}:kms:${var.region}:${local.account_id}:key/*",
  ]

  log_group_arns = length(var.iam_cloudwatch_log_group_arns) > 0 ? var.iam_cloudwatch_log_group_arns : [
    "arn:${local.partition}:logs:${var.region}:${local.account_id}:log-group:/${var.project}/*",
    "arn:${local.partition}:logs:${var.region}:${local.account_id}:log-group:/${var.project}/*:log-stream:*",
  ]
}

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

# Read-only EC2 describe (Resource="*" required by AWS for these actions)
resource "aws_iam_role_policy" "main_ec2_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.iam_enable_ec2_describe ? 1 : 0

  name = "${local.name}-ec2-describe-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2DescribeReadOnly"
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

resource "aws_iam_role_policy" "main_rds_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_rds ? 1 : 0

  name = "${local.name}-rds-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "RDSDescribe"
          Effect = "Allow"
          Action = [
            "rds:DescribeDBInstances",
            "rds:DescribeDBClusters",
            "rds:DescribeDBClusterEndpoints",
            "rds:ListTagsForResource"
          ]
          # Describe* on RDS is typically Resource="*"; keep narrow list of actions only.
          Resource = "*"
        },
        {
          Sid      = "SecretsRead"
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          Resource = local.secrets_arns
        }
      ],
      length(local.kms_key_arns) > 0 ? [
        {
          Sid      = "KmsDecryptViaSecretsManager"
          Effect   = "Allow"
          Action   = ["kms:Decrypt"]
          Resource = local.kms_key_arns
          Condition = {
            StringEquals = {
              "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
            }
          }
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy" "main_elasticache_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_elasticache ? 1 : 0

  name = "${local.name}-elasticache-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ElastiCacheDescribe"
        Effect = "Allow"
        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:DescribeReplicationGroups",
          "elasticache:DescribeCacheSubnetGroups",
          "elasticache:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "main_ecr_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_ecr ? 1 : 0

  name = "${local.name}-ecr-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "ECRAuthToken"
          Effect   = "Allow"
          Action   = ["ecr:GetAuthorizationToken"]
          Resource = "*"
        },
        {
          Sid    = "ECRPull"
          Effect = "Allow"
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages"
          ]
          Resource = local.ecr_repository_arns
        }
      ],
      var.iam_ecr_allow_push ? [
        {
          Sid    = "ECRPush"
          Effect = "Allow"
          Action = [
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload"
          ]
          Resource = local.ecr_repository_arns
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy" "main_eks_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_eks ? 1 : 0

  name = "${local.name}-eks-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EKSListClusters"
        Effect   = "Allow"
        Action   = ["eks:ListClusters"]
        Resource = "*"
      },
      {
        Sid    = "EKSDescribeCluster"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListAddons",
          "eks:DescribeAddon"
        ]
        Resource = local.eks_cluster_arns
      }
    ]
  })
}

resource "aws_iam_role_policy" "main_ecs_access" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_ecs ? 1 : 0

  name = "${local.name}-ecs-access-policy"
  role = aws_iam_role.main[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "ECSList"
          Effect   = "Allow"
          Action   = ["ecs:ListClusters", "ecs:ListTaskDefinitions", "ecs:ListServices", "ecs:ListTasks"]
          Resource = "*"
        },
        {
          Sid    = "ECSDescribe"
          Effect = "Allow"
          Action = [
            "ecs:DescribeClusters",
            "ecs:DescribeServices",
            "ecs:DescribeTasks",
            "ecs:DescribeTaskDefinition",
            "ecs:DescribeContainerInstances",
            "ecs:ListTagsForResource"
          ]
          Resource = concat(local.ecs_cluster_arns, local.ecs_service_arns, local.ecs_task_definition_arns)
        },
        {
          Sid      = "LogsRead"
          Effect   = "Allow"
          Action   = ["logs:GetLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"]
          Resource = local.log_group_arns
        }
      ],
      var.iam_ecs_allow_task_run ? [
        {
          Sid      = "ECSRunStopTask"
          Effect   = "Allow"
          Action   = ["ecs:RunTask", "ecs:StopTask"]
          Resource = local.ecs_task_definition_arns
          Condition = {
            ArnEquals = {
              "ecs:cluster" = local.ecs_cluster_arns
            }
          }
        }
      ] : [],
      var.iam_ecs_allow_mutations ? [
        {
          Sid      = "ECSServiceMutations"
          Effect   = "Allow"
          Action   = ["ecs:UpdateService", "ecs:CreateService", "ecs:DeleteService"]
          Resource = local.ecs_service_arns
        },
        {
          Sid      = "ECSRegisterTaskDefinition"
          Effect   = "Allow"
          Action   = ["ecs:RegisterTaskDefinition", "ecs:DeregisterTaskDefinition"]
          Resource = local.ecs_task_definition_arns
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy" "main_custom" {
  for_each = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? var.iam_role_policies : {}

  name   = each.key
  role   = aws_iam_role.main[0].id
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "main_managed" {
  for_each = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null ? toset(concat(var.iam_role_policy_arns, var.ec2_external_policy_arns)) : toset([])

  role       = aws_iam_role.main[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "main_ssm" {
  count = var.iam_instance_profile_enabled && var.iam_instance_profile_name == null && var.enable_ssm_session_manager ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

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
