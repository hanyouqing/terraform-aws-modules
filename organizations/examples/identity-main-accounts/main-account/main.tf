terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  profile    = var.aws_profile
  token      = var.aws_session_token

  dynamic "assume_role" {
    for_each = var.aws_assume_role_arn != null ? [1] : []
    content {
      role_arn     = var.aws_assume_role_arn
      session_name = var.aws_assume_role_session_name
      external_id  = var.aws_assume_role_external_id
    }
  }
}

resource "aws_iam_role" "team_roles" {
  for_each = var.team_roles

  name = each.value.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.identity_account_id}:role/${each.value.assume_role_name}"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = each.value.external_id
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = each.value.role_name
      Purpose   = "Team role for ${each.key}"
      Team      = each.key
      ManagedBy = "terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "team_policies" {
  for_each = {
    for team_role in flatten([
      for team, config in var.team_roles : [
        for policy_arn in config.policy_arns : {
          key        = "${team}-${replace(policy_arn, "/", "-")}"
          team       = team
          role_name  = config.role_name
          policy_arn = policy_arn
        }
      ]
    ]) : team_role.key => team_role
  }

  role       = aws_iam_role.team_roles[each.value.team].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "team_inline_policies" {
  for_each = {
    for k, v in var.team_roles : k => v
    if length(v.inline_policies) > 0
  }

  name = "${each.value.role_name}-inline-policy"
  role = aws_iam_role.team_roles[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = each.value.inline_policies
  })
}

