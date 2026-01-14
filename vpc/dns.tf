# Public Route53 Hosted Zone
resource "aws_route53_zone" "public" {
  count = var.domain != null ? 1 : 0

  name = "${var.environment}.${var.domain}"

  comment = "Public hosted zone for ${var.environment} environment"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-public-hosted-zone"
      Type = "public-hosted-zone"
    }
  )
}

# Private Route53 Hosted Zone (for internal services like Redis, Database, etc.)
# Automatically created when domain is specified
# Uses the same domain as public hosted zone (e.g., development.example.com)
# This allows creating CNAME/ALIAS records for internal services within the same domain
# The private zone is associated with the VPC and only accessible from within the VPC
resource "aws_route53_zone" "private" {
  count = var.domain != null ? 1 : 0

  name = "${var.environment}.${var.domain}"

  vpc {
    vpc_id     = aws_vpc.main.id
    vpc_region = var.region
  }

  comment = "Private hosted zone for internal services (Redis, Database, etc.) in ${var.environment} environment"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-hosted-zone"
      Type = "private-hosted-zone"
    }
  )
}
