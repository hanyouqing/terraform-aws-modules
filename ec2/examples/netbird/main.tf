terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC module must be deployed first
data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = var.vpc_remote_state_bucket
    key                  = var.vpc_remote_state_key
    region               = var.region
    workspace_key_prefix = "env:development"
  }
}

module "ec2" {
  source = "../../"

  project     = var.project
  environment = var.environment
  region      = var.region

  vpc_remote_state_bucket               = var.vpc_remote_state_bucket
  vpc_remote_state_key                  = var.vpc_remote_state_key
  vpc_remote_state_workspace_key_prefix = "env:development"

  instance_count = var.instance_count

  # SSH key configuration
  key_path = var.key_path

  instance_defaults = {
    instance_type                 = var.instance_type
    enable_monitoring             = var.enable_monitoring
    ebs_volume_size               = var.ebs_volume_size
    ebs_volume_type               = var.ebs_volume_type
    ebs_encrypted                 = var.ebs_encrypted
    enable_termination_protection = var.enable_termination_protection
  }

  # NetBird configuration
  netbird_enabled = true

  # NetBird setup key (required)
  netbird_setup_key = var.netbird_setup_key

  # NetBird management URL (optional, for self-hosted management server)
  netbird_management_url = var.netbird_management_url

  # SSM Session Manager
  enable_ssm_session_manager = var.enable_ssm_session_manager

  # Elastic IP for stable public IP
  enable_eip = var.enable_eip

  # DNS configuration
  domain      = var.domain
  dns_enabled = var.dns_enabled
  dns_ttl     = var.dns_ttl

  tags = var.tags
}
