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

module "vpc" {
  source = "../../"

  project     = var.project
  environment = var.environment
  region      = var.region

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  database_subnets   = var.database_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_flow_log           = var.enable_flow_log
  flow_log_destination_type = var.flow_log_destination_type

  # Allowlist configuration
  allowlist_ipv4_blocks = var.allowlist_ipv4_blocks
  allowlist_ipv6_blocks = var.allowlist_ipv6_blocks

  enable_public_security_group = var.enable_public_security_group

  # Domain and DNS
  domain = var.domain

  # VPC Endpoints
  enable_vpc_endpoints            = var.enable_vpc_endpoints
  enable_ecr_dkr_endpoint         = var.enable_ecr_dkr_endpoint
  enable_ecr_api_endpoint         = var.enable_ecr_api_endpoint
  enable_eks_endpoint             = var.enable_eks_endpoint
  enable_cloudwatch_logs_endpoint = var.enable_cloudwatch_logs_endpoint
  enable_secretsmanager_endpoint  = var.enable_secretsmanager_endpoint
  enable_s3_endpoint              = var.enable_s3_endpoint

  tags = var.tags
}

