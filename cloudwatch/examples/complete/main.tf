terraform {
  required_version = ">= 1.14.2"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.28" }
  }
}

provider "aws" { region = var.region }

module "cloudwatch" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  log_groups  = { app = { retention_in_days = 90 } }
  metric_alarms = {
    high_cpu = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      dimensions          = { InstanceId = "i-placeholder" }
    }
  }
}
