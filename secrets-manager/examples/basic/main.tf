terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "secrets" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  secrets = {
    app = { description = "App placeholder secret (set version via CI)" }
  }
}
