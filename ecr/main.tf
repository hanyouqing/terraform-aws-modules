resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = coalesce(each.value.name, "${var.project}-${var.environment}-${each.key}")
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.encryption_type == "KMS" ? each.value.kms_key_arn : null
  }

  tags = merge(local.common_tags, each.value.tags, { Name = each.key })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = { for k, v in var.repositories : k => v if v.enable_lifecycle_policy }

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${each.value.lifecycle_keep_last_images} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = each.value.lifecycle_keep_last_images
      }
      action = { type = "expire" }
    }]
  })
}
