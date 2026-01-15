# Security group for EC2 instances (always created)
resource "aws_security_group" "main" {
  name        = "${local.name}-sg"
  description = "Security group for ${local.name} instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-sg"
    }
  )
}

# Custom security group rules
resource "aws_security_group_rule" "custom" {
  for_each = var.security_group_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null
  ipv6_cidr_blocks         = length(each.value.ipv6_cidr_blocks) > 0 ? each.value.ipv6_cidr_blocks : null
  prefix_list_ids          = length(each.value.prefix_list_ids) > 0 ? each.value.prefix_list_ids : null
  security_group_id        = aws_security_group.main.id
  source_security_group_id = each.value.source_security_group_id

  description = each.value.description != "" ? each.value.description : "${each.key} rule"
}

# Security group rules to allow ALB access to instances
resource "aws_security_group_rule" "alb_to_instance" {
  for_each = var.enable_alb ? {
    for port in [var.alb_target_port] : port => port
  } : {}

  type                     = "ingress"
  from_port                = each.value
  to_port                  = each.value
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb[0].id
  security_group_id        = aws_security_group.main.id
  description              = "Allow ALB to access instances on port ${each.value}"
}

# Security group rules to allow ELB access to instances
resource "aws_security_group_rule" "elb_to_instance" {
  for_each = var.enable_elb ? {
    for port in [var.elb_instance_port] : port => port
  } : {}

  type                     = "ingress"
  from_port                = each.value
  to_port                  = each.value
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.elb[0].id
  security_group_id        = aws_security_group.main.id
  description              = "Allow ELB to access instances on port ${each.value}"
}
