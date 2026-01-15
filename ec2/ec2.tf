resource "aws_instance" "main" {
  # Only create instances if ASG is not enabled
  for_each = var.enable_autoscaling ? {} : local.instances

  ami           = local.ami_id
  instance_type = var.spot_instance_enabled && var.spot_instance_type != null ? var.spot_instance_type : each.value.instance_type
  key_name      = each.value.key_name

  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = length(each.value.security_group_ids) > 0 ? each.value.security_group_ids : []

  associate_public_ip_address = each.value.associate_public_ip

  iam_instance_profile = var.iam_instance_profile_enabled ? (
    var.iam_instance_profile_name != null ? var.iam_instance_profile_name : aws_iam_instance_profile.main[0].name
  ) : null

  ipv6_address_count = var.enable_ipv6 ? var.ipv6_address_count : 0

  monitoring = each.value.enable_monitoring

  # Termination protection is not supported for Spot instances
  disable_api_termination = var.spot_instance_enabled ? false : each.value.enable_termination_protection

  # Spot instance configuration
  dynamic "instance_market_options" {
    for_each = var.spot_instance_enabled ? [1] : []
    content {
      market_type = "spot"

      spot_options {
        max_price                      = var.spot_price != null ? var.spot_price : (var.spot_max_price != null ? var.spot_max_price : null)
        spot_instance_type             = "one-time"
        instance_interruption_behavior = var.spot_interruption_behavior
      }
    }
  }

  dynamic "metadata_options" {
    for_each = each.value.metadata_options != null ? [each.value.metadata_options] : []
    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")
      http_tokens                 = try(metadata_options.value.http_tokens, "required")
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 2)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, "enabled")
    }
  }

  root_block_device {
    volume_size           = each.value.ebs_volume_size
    volume_type           = each.value.ebs_volume_type
    encrypted             = each.value.ebs_encrypted
    kms_key_id            = each.value.ebs_kms_key_id
    delete_on_termination = true
  }

  # Use user_data for plain text scripts (AWS provider will auto-encode to base64)
  # The warning about base64 encoding is a false positive - our content is plain text
  user_data = each.value.userdata_content != null && each.value.userdata_content != "" ? each.value.userdata_content : null

  user_data_replace_on_change = each.value.user_data_replace_on_change

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }

  tags = merge(
    each.value.tags,
    {
      Name = each.value.name
      Type = var.name_prefix
    }
  )

  volume_tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = "${each.value.name}-volume"
      Type = "ebs-volume"
    }
  )
}

# Additional EBS volumes - key format: instance_name.volume_name
locals {
  additional_volumes_flat = {
    for k, v in var.additional_ebs_volumes : k => {
      instance_name = split(".", k)[0]
      volume_name   = length(split(".", k)) > 1 ? join(".", slice(split(".", k), 1, length(split(".", k)))) : "volume"
      volume_config = v
    }
  }
}

resource "aws_ebs_volume" "additional" {
  for_each = var.additional_ebs_volumes

  availability_zone = aws_instance.main[local.additional_volumes_flat[each.key].instance_name].availability_zone
  size              = each.value.size
  type              = each.value.type
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id

  tags = merge(
    local.common_tags,
    try(each.value.tags, {}),
    {
      Name = "${each.key}-${each.value.size}gb"
      Type = "ebs-volume"
    }
  )
}

resource "aws_volume_attachment" "additional" {
  for_each = var.additional_ebs_volumes

  device_name = each.value.device_name != null ? each.value.device_name : "/dev/sdf"
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.main[local.additional_volumes_flat[each.key].instance_name].id
}


