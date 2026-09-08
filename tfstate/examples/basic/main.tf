terraform {
  required_version = ">= 1.14.2"

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

module "tfstate" {
  source = "../../"

  project     = var.project
  environment = var.environment
  region      = var.region

  create_iam_user       = false
  create_iam_access_key = false
}
