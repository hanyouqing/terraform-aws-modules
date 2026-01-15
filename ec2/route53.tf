resource "aws_route53_record" "main" {
  for_each = local.dns_enabled && !var.enable_alb ? local.instance_dns_names : {}

  zone_id = local.hosted_zone_id
  name    = each.value
  type    = "A"
  ttl     = var.dns_ttl
  records = [local.instances_output[each.key].public_ip]
}

resource "aws_route53_record" "main_alb" {
  for_each = local.dns_enabled && var.enable_alb ? local.instance_dns_names : {}

  zone_id = local.hosted_zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = var.dns_ttl
  records = [aws_lb.main[0].dns_name]
}

resource "aws_route53_record" "main_private" {
  for_each = local.dns_enabled && local.private_hosted_zone_name != null ? local.instance_private_dns_names : {}

  zone_id = try(data.terraform_remote_state.vpc.outputs.private_hosted_zone_id, null)
  name    = each.value
  type    = "A"
  ttl     = var.dns_ttl
  records = [local.instances_output[each.key].private_ip]
}

resource "aws_route53_record" "main_cname" {
  for_each = local.dns_enabled && length(local.instance_dns_names) > 0 ? local.instance_dns_names : {}

  zone_id = local.hosted_zone_id
  name    = "${var.name_prefix}.${var.environment}.${local.base_domain}"
  type    = "CNAME"
  ttl     = var.dns_ttl
  records = [each.value]

  weighted_routing_policy {
    weight = 100
  }

  set_identifier = each.key
}

# Project-based DNS record for jump and gitlab (e.g., jump.production.aws.hanyouqing.com -> ALB)
resource "aws_route53_record" "project_alb" {
  count = local.dns_enabled && local.project_dns_name != null && var.enable_alb && length(aws_lb.main) > 0 ? 1 : 0

  zone_id = local.hosted_zone_id
  name    = local.project_dns_name
  type    = "CNAME"
  ttl     = var.dns_ttl
  records = [aws_lb.main[0].dns_name]
}
