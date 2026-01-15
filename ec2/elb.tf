# ==============================================================================
# Classic Load Balancer (ELB)
# ==============================================================================

locals {
  elb_subnet_type_resolved = var.elb_subnet_type != null ? var.elb_subnet_type : (var.elb_internal ? "private" : "public")
  elb_subnet_ids = local.elb_subnet_type_resolved == "private" ? data.terraform_remote_state.vpc.outputs.private_subnet_ids : (
    local.elb_subnet_type_resolved == "database" ? data.terraform_remote_state.vpc.outputs.database_subnet_ids : data.terraform_remote_state.vpc.outputs.public_subnet_ids
  )
  elb_name = "${local.name}-elb"
}

resource "aws_security_group" "elb" {
  count = var.enable_elb ? 1 : 0

  name        = "${local.name}-elb-sg"
  description = "Security group for ${local.name} ELB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.elb_listener_port
    to_port     = var.elb_listener_port
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
      Name = "${local.name}-elb-sg"
      Type = "elb-security-group"
    }
  )
}

resource "aws_elb" "main" {
  count = var.enable_elb ? 1 : 0

  name            = local.elb_name
  internal        = var.elb_internal
  subnets         = local.elb_subnet_ids
  security_groups = [aws_security_group.elb[0].id]

  listener {
    instance_port      = var.elb_instance_port
    instance_protocol  = var.elb_instance_protocol
    lb_port            = var.elb_listener_port
    lb_protocol        = var.elb_listener_protocol
    ssl_certificate_id = var.elb_listener_protocol == "HTTPS" || var.elb_listener_protocol == "SSL" ? var.elb_certificate_id : null
  }

  health_check {
    healthy_threshold   = var.elb_health_check_healthy_threshold
    unhealthy_threshold = var.elb_health_check_unhealthy_threshold
    timeout             = var.elb_health_check_timeout
    interval            = var.elb_health_check_interval
    target              = var.elb_health_check_target
  }

  instances                   = [for k, v in aws_instance.main : v.id]
  cross_zone_load_balancing   = var.elb_cross_zone_load_balancing
  connection_draining         = var.elb_connection_draining
  connection_draining_timeout = var.elb_connection_draining_timeout
  idle_timeout                = var.elb_idle_timeout

  tags = merge(
    local.common_tags,
    {
      Name = local.elb_name
      Type = "elb"
    }
  )
}
