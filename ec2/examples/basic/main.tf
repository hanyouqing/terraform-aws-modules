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
# Note: This data source is duplicated in the module's data.tf
# It's kept here for reference but the module's data source will be used
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
    instance_type                 = "t3.micro"
    enable_monitoring             = false
    ebs_volume_size               = 8
    enable_termination_protection = false
  }

  # DNS configuration
  domain      = var.domain
  dns_enabled = var.dns_enabled
  dns_ttl     = var.dns_ttl

  tags = var.tags
}
