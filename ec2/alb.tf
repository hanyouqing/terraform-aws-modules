# ==============================================================================
# Application Load Balancer (ALB)
# ==============================================================================

locals {
  alb_subnet_type_resolved = var.alb_subnet_type != null ? var.alb_subnet_type : (var.alb_internal ? "private" : "public")
  alb_subnet_ids = local.alb_subnet_type_resolved == "private" ? data.terraform_remote_state.vpc.outputs.private_subnet_ids : (
    local.alb_subnet_type_resolved == "database" ? data.terraform_remote_state.vpc.outputs.database_subnet_ids : data.terraform_remote_state.vpc.outputs.public_subnet_ids
  )
  alb_name = "${local.name}-alb"
}

resource "aws_security_group" "alb" {
  count = var.enable_alb ? 1 : 0

  name        = "${local.name}-alb-sg"
  description = "Security group for ${local.name} ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-alb-sg"
      Type = "alb-security-group"
    }
  )
}

resource "aws_lb" "main" {
  count = var.enable_alb ? 1 : 0

  name               = local.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = local.alb_subnet_ids

  enable_deletion_protection = var.alb_enable_deletion_protection
  enable_http2               = true

  tags = merge(
    local.common_tags,
    {
      Name = local.alb_name
      Type = "alb"
    }
  )
}

resource "aws_lb_target_group" "main" {
  count = var.enable_alb ? 1 : 0

  name     = "${local.name}-tg"
  port     = var.alb_target_port
  protocol = var.alb_target_protocol
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    timeout             = var.alb_health_check_timeout
    interval            = var.alb_health_check_interval
    path                = var.alb_health_check_path
    port                = var.alb_health_check_port != null ? tostring(var.alb_health_check_port) : "traffic-port"
    protocol            = var.alb_health_check_protocol
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-tg"
      Type = "alb-target-group"
    }
  )
}

resource "aws_lb_listener" "main" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = local.alb_protocol_resolved == "HTTPS" ? 443 : var.alb_port
  protocol          = local.alb_protocol_resolved

  certificate_arn = local.alb_protocol_resolved == "HTTPS" ? local.alb_certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

# HTTP to HTTPS redirect listener (only when HTTPS is enabled)
resource "aws_lb_listener" "redirect" {
  count = var.enable_alb && local.alb_protocol_resolved == "HTTPS" ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "main" {
  for_each = var.enable_alb ? local.instances : {}

  target_group_arn = aws_lb_target_group.main[0].arn
  target_id        = aws_instance.main[each.key].id
  port             = var.alb_target_port
}
