terraform {
  backend "s3" {
    # Configure your S3 backend here
    # bucket               = "your-terraform-state-bucket"
    # key                  = "hanyouqing/terraform-aws-modules:ec2/examples/netbird/terraform.tfstate"
    # region               = "us-east-1"
    # encrypt              = true
    # use_lockfile         = true
    # workspace_key_prefix = "env:production"
  }
}
