data "local_file" "ssh_public_key" {
  count    = local.local_ssh_key_exists ? 1 : 0
  filename = local.local_ssh_key_expanded_path
}

resource "aws_key_pair" "main" {
  count = local.local_ssh_key_exists ? 1 : 0

  key_name   = local.key_pair_name
  public_key = data.local_file.ssh_public_key[0].content

  tags = merge(
    local.common_tags,
    {
      Name = local.key_pair_name
      Type = "ec2-key-pair"
    }
  )
}
