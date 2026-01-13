resource "aws_acm_certificate" "environment" {
  count = var.domain != null ? 1 : 0

  domain_name       = "${var.environment}.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = var.environment == "production" ? [
    "*.${var.environment}.${var.domain}",
    "*.${var.domain}"
    ] : [
    "*.${var.environment}.${var.domain}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-certificate"
      Type = "acm-certificate"
    }
  )
}

resource "aws_acm_certificate_validation" "environment" {
  count = var.domain != null ? 1 : 0

  certificate_arn = aws_acm_certificate.environment[0].arn

  validation_record_fqdns = [
    for record in aws_route53_record.certificate_validation : record.fqdn
  ]

  timeouts {
    create = "5m"
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = var.domain != null ? {
    for dvo in aws_acm_certificate.environment[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.domain != null ? aws_route53_zone.main[0].zone_id : null
}

