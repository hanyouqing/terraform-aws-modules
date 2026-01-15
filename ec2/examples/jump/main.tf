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

  # Subnet configuration: JumpServer should be in public subnet for direct access
  subnet_type = "public"

  instance_defaults = {
    instance_type                 = var.instance_type
    enable_monitoring             = var.enable_monitoring
    ebs_volume_size               = var.ebs_volume_size
    ebs_volume_type               = var.ebs_volume_type
    ebs_encrypted                 = var.ebs_encrypted
    enable_termination_protection = var.enable_termination_protection
  }

  # JumpServer configuration
  enable_jump  = true
  jump_version = var.jump_version

  # JumpServer database configuration
  jump_db_host     = var.jump_db_host
  jump_db_port     = var.jump_db_port
  jump_db_user     = var.jump_db_user
  jump_db_password = var.jump_db_password
  jump_db_name     = var.jump_db_name

  # JumpServer Redis configuration
  jump_redis_host     = var.jump_redis_host
  jump_redis_port     = var.jump_redis_port
  jump_redis_password = var.jump_redis_password

  # JumpServer ports
  jump_http_port = var.jump_http_port
  jump_ssh_port  = var.jump_ssh_port
  jump_rdp_port  = var.jump_rdp_port

  # IAM permissions
  iam_instance_profile_enabled = var.iam_instance_profile_enabled
  enable_rds                   = var.enable_rds
  enable_ecr                   = var.enable_ecr
  enable_eks                   = var.enable_eks
  enable_elasticache           = var.enable_elasticache

  # SSM Session Manager
  enable_ssm_session_manager = var.enable_ssm_session_manager

  # Elastic IP for stable public IP
  enable_eip = var.enable_eip

  # Application Load Balancer (enabled by default for HTTPS and security)
  enable_alb          = var.enable_alb
  alb_port            = var.alb_port
  alb_protocol        = var.alb_protocol
  alb_target_port     = var.alb_target_port
  alb_certificate_arn = var.alb_certificate_arn

  # DNS configuration
  domain      = var.domain
  dns_enabled = var.dns_enabled
  dns_ttl     = var.dns_ttl

  tags = var.tags
}
