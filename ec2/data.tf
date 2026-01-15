data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = var.vpc_remote_state_bucket
    key                  = var.vpc_remote_state_key
    region               = var.region
    workspace_key_prefix = var.vpc_remote_state_workspace_key_prefix
  }
}

# Ubuntu AMI lookups
data "aws_ssm_parameter" "ubuntu_24_04_ami" {
  count = var.ami_id == null && var.os_type == "ubuntu" && (var.ubuntu_version == "24.04" || var.os_version == "24.04") ? 1 : 0
  name  = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# Amazon Linux 2023 AMI lookup
data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  count = var.ami_id == null && var.os_type == "amazon-linux" && var.os_version == "2023" ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# RHEL AMI lookups
data "aws_ssm_parameter" "rhel_9_ami" {
  count = var.ami_id == null && var.os_type == "rhel" && var.os_version == "9" ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # Note: RHEL requires Red Hat account, using placeholder
}

data "aws_ssm_parameter" "rhel_8_ami" {
  count = var.ami_id == null && var.os_type == "rhel" && var.os_version == "8" ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # Note: RHEL requires Red Hat account, using placeholder
}

# Debian AMI lookups
data "aws_ssm_parameter" "debian_12_ami" {
  count = var.ami_id == null && var.os_type == "debian" && var.os_version == "12" ? 1 : 0
  name  = "/aws/service/debian/release/12/latest/amd64"
}

data "aws_ssm_parameter" "debian_11_ami" {
  count = var.ami_id == null && var.os_type == "debian" && var.os_version == "11" ? 1 : 0
  name  = "/aws/service/debian/release/11/latest/amd64"
}

# Custom AMI lookup - only used when SSM Parameter Store lookup is not applicable
# This is a fallback for custom AMI name filters when SSM Parameter Store doesn't support the OS type/version
data "aws_ami" "custom" {
  count = var.ami_id == null && var.ami_name_filter != null && (
    # Only use custom AMI lookup if not using SSM Parameter Store
    # SSM Parameter Store is used for: ubuntu 24.04, amazon-linux 2023, rhel 8/9, debian 11/12
    !(var.os_type == "ubuntu" && (var.ubuntu_version == "24.04" || var.os_version == "24.04")) &&
    !(var.os_type == "amazon-linux" && var.os_version == "2023") &&
    !(var.os_type == "rhel" && (var.os_version == "8" || var.os_version == "9")) &&
    !(var.os_type == "debian" && (var.os_version == "11" || var.os_version == "12"))
  ) ? 1 : 0

  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

