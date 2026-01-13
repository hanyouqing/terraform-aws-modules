# Restrict Default Security Group
# This is a security best practice - the default security group should deny all traffic
# Users should create and use custom security groups instead

resource "aws_default_security_group" "main" {
  count = var.restrict_default_security_group ? 1 : 0

  vpc_id = aws_vpc.main.id

  # Remove all default ingress rules (deny all ingress)
  ingress = []

  # Remove all default egress rules (deny all egress)
  egress = []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-default-sg-restricted"
      Type = "default-security-group"
    }
  )
}
