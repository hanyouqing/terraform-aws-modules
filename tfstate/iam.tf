resource "aws_iam_user" "terraform" {
  name = "${var.project}-terraform-user-${var.environment}"
  path = "/"

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.project}-terraform-user-${var.environment}"
      Description = "IAM user for Terraform operations"
    }
  )
}

resource "aws_iam_user_policy" "terraform_state" {
  name = "${var.project}-terraform-state-policy-${var.environment}"
  user = aws_iam_user.terraform.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Sid    = "S3StateObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Sid    = "DynamoDBStateLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = aws_dynamodb_table.terraform_state_lock.arn
      }
    ]
  })
}

resource "aws_iam_access_key" "terraform" {
  user = aws_iam_user.terraform.name
}

