resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = each.value.bucket != null ? each.value.bucket : (each.value.bucket_prefix != null ? null : each.key)
  bucket_prefix = each.value.bucket_prefix
  force_destroy = each.value.force_destroy

  tags = merge(local.common_tags, each.value.tags, { Name = coalesce(each.value.bucket, each.key) })
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.sse_algorithm
      kms_master_key_id = each.value.sse_algorithm == "aws:kms" ? each.value.kms_key_id : null
    }
    bucket_key_enabled = each.value.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = each.value.object_ownership
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for k, v in var.buckets : k => v if v.enable_lifecycle }
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = each.value.lifecycle_noncurrent_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_logging" "this" {
  for_each = { for k, v in var.buckets : k => v if v.enable_access_logging && v.access_log_bucket != null }
  bucket   = aws_s3_bucket.this[each.key].id

  target_bucket = each.value.access_log_bucket
  target_prefix = each.value.access_log_prefix
}

resource "aws_s3_bucket_policy" "tls_only" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.this[each.key].arn,
        "${aws_s3_bucket.this[each.key].arn}/*"
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })
}
