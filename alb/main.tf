resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = true

  tags = merge(local.common_tags, { Name = var.name })
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                 = substr("${var.name}-${each.key}", 0, 32)
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = each.value.target_type
  deregistration_delay = each.value.deregistration_delay

  health_check {
    path    = each.value.health_check_path
    matcher = each.value.health_check_matcher
  }

  tags = merge(local.common_tags, { Name = "${var.name}-${each.key}" })
}

resource "aws_lb_listener" "http" {
  for_each = var.http_listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }
}

resource "aws_lb_listener" "https" {
  for_each = var.https_listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = "HTTPS"
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }
}
