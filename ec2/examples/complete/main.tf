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

  vpc_remote_state_bucket = var.vpc_remote_state_bucket
  vpc_remote_state_key    = var.vpc_remote_state_key

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

  # SSM Session Manager (optional)
  enable_ssm_session_manager = var.enable_ssm_session_manager

  # CloudWatch configuration (optional)
  cloudwatch_logs_enabled        = var.cloudwatch_logs_enabled
  cloudwatch_logs_retention_days = var.cloudwatch_logs_retention_days
  cloudwatch_metrics_enabled     = var.cloudwatch_metrics_enabled

  # IAM permissions
  iam_instance_profile_enabled = var.iam_instance_profile_enabled
  enable_rds                   = var.enable_rds
  enable_ecr                   = var.enable_ecr
  enable_eks                   = var.enable_eks
  enable_elasticache           = var.enable_elasticache

  # DNS configuration
  domain      = var.domain
  dns_enabled = var.dns_enabled
  dns_ttl     = var.dns_ttl

  # IPv6 support
  enable_ipv6 = var.enable_ipv6

  # Elastic IP
  enable_eip = var.enable_eip

  # Load Balancer configuration
  enable_alb            = var.enable_alb
  alb_port              = var.alb_port
  alb_target_port       = var.alb_target_port
  alb_protocol          = var.alb_protocol
  alb_target_protocol   = var.alb_target_protocol
  enable_elb            = var.enable_elb
  elb_listener_port     = var.elb_listener_port
  elb_instance_port     = var.elb_instance_port
  elb_listener_protocol = var.elb_listener_protocol

  # Spot instance configuration
  spot_instance_enabled      = var.spot_instance_enabled
  spot_instance_type         = var.spot_instance_type
  spot_interruption_behavior = var.spot_interruption_behavior
  spot_price                 = var.spot_price

  # Auto Scaling Group configuration
  enable_autoscaling   = var.enable_autoscaling
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity

  tags = var.tags
}
