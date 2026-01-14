resource "aws_acm_certificate" "environment" {
  count = var.domain != null ? 1 : 0

  domain_name       = "${var.environment}.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = var.environment == "production" ? [
    "${var.environment}.${var.domain}",
    "*.${var.environment}.${var.domain}",
    "*.${var.domain}"
  ] : [
    "${var.environment}.${var.domain}",
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

# DNS validation records for ACM certificate
# These records must be created in the public hosted zone for ACM to validate the certificate
# IMPORTANT: Ensure the public hosted zone's NS records are configured in the parent domain
# (e.g., if domain is "development.aws.hanyouqing.com", add NS records for "development" 
# in the "aws.hanyouqing.com" hosted zone)
resource "aws_route53_record" "certificate_validation" {
  for_each = var.domain != null ? {
    for dvo in aws_acm_certificate.environment[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  # Remove trailing dot from resource_record_name if present (Route53 handles this automatically)
  name            = trimsuffix(each.value.name, ".")
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.domain != null ? aws_route53_zone.public[0].zone_id : null

  # Ensure the public hosted zone exists before creating validation records
  depends_on = [aws_route53_zone.public]
}

# ACM Certificate Validation
# Waits for DNS validation records to be created and propagated
# 
# IMPORTANT: For validation to succeed, you MUST:
# 1. Configure NS records in the parent domain pointing to the public hosted zone's name servers
# 2. Wait for DNS propagation (can take up to 48 hours, typically 5-30 minutes)
# 3. Ensure DNS validation records are accessible from the internet
#
# If validation fails, check:
# - Are NS records configured in parent domain? (use: terraform output hosted_zone_name_servers)
# - Can you resolve the validation record? (dig TXT _acme-challenge.development.aws.hanyouqing.com)
# - Is the public hosted zone accessible from the internet?
resource "aws_acm_certificate_validation" "environment" {
  count = var.domain != null ? 1 : 0

  certificate_arn = aws_acm_certificate.environment[0].arn

  # Wait for all DNS validation records to be created
  validation_record_fqdns = [
    for record in aws_route53_record.certificate_validation : record.fqdn
  ]

  # Increase timeout to allow DNS propagation (ACM validation can take 5-30 minutes, 
  # but may take longer if NS records are not configured in parent domain)
  timeouts {
    create = "45m"
  }

  # Ensure DNS records are created before validation
  depends_on = [aws_route53_record.certificate_validation]
}

