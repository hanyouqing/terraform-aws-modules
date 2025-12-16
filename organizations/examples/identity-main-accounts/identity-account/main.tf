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

# IAM roles in identity account that can be assumed by SSO users
# These roles have no permissions except assuming roles in main account
resource "aws_iam_role" "assume_main_account_role" {
  for_each = var.team_roles

  name = each.value.role_name

  # Allow SSO users (via permission sets) and OrganizationAccountAccessRole to assume this role
  # SSO creates temporary roles with pattern: arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/<region>/<permission-set-id>
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.identity_account_id}:role/OrganizationAccountAccessRole"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.identity_account_id}:role/aws-reserved/sso.amazonaws.com/*"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = each.value.role_name
      Purpose   = "Assume role to main account"
      Team      = each.key
      ManagedBy = "terraform"
    }
  )
}

# Deny all actions by default
resource "aws_iam_role_policy" "deny_all" {
  for_each = aws_iam_role.assume_main_account_role

  name = "${each.value.name}-deny-all"
  role = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# Allow assuming the corresponding role in main account
resource "aws_iam_role_policy" "allow_assume_role" {
  for_each = aws_iam_role.assume_main_account_role

  name = "${each.value.name}-allow-assume-role"
  role = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = [
          "arn:aws:iam::${var.main_account_id}:role/${each.value.target_role_name}"
        ]
        Condition = {
          StringEquals = {
            "sts:ExternalId" = each.value.external_id
          }
        }
      }
    ]
  })
}

