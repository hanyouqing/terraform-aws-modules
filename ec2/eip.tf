# Elastic IP resources for instances in public subnets
resource "aws_eip" "main" {
  for_each = var.enable_eip ? {
    for hostname, instance in local.instances : hostname => instance
    if instance.associate_public_ip == true
  } : {}

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${each.value.name}-eip"
      Type = "elastic-ip"
    }
  )

  depends_on = [aws_instance.main]
}

# Associate Elastic IP with EC2 instance
resource "aws_eip_association" "main" {
  for_each = var.enable_eip ? {
    for hostname, instance in local.instances : hostname => instance
    if instance.associate_public_ip == true
  } : {}

  instance_id   = aws_instance.main[each.key].id
  allocation_id = aws_eip.main[each.key].id
}
