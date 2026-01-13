# Public Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.domain != null ? 1 : 0

  name = "${var.environment}.${var.domain}"

  comment = "Hosted zone for ${var.environment} environment"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-hosted-zone"
      Type = "hosted-zone"
    }
  )
}

# Private Route53 Hosted Zone (production only)
resource "aws_route53_zone" "private" {
  count = var.environment == "production" && var.domain != null ? 1 : 0

  name = "private-production.${var.domain}"

  vpc {
    vpc_id     = aws_vpc.main.id
    vpc_region = var.region
  }

  comment = "Private hosted zone for production environment"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-hosted-zone"
      Type = "private-hosted-zone"
    }
  )
}
