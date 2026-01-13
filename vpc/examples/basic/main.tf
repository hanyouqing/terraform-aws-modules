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

  # Cost optimization: Disable NAT Gateway and Flow Logs by default for minimal cost
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_flow_log = var.enable_flow_log

  tags = var.tags
}

