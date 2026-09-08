terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "ecr" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  repositories = {
    api = {
      image_tag_mutability       = "IMMUTABLE"
      scan_on_push               = true
      lifecycle_keep_last_images = 50
    }
  }
}
