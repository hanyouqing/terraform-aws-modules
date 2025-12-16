resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name        = local.table_name
      Description = "Terraform state locking table"
    }
  )
}

