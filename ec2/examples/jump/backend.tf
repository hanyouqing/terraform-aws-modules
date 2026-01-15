terraform {
  backend "s3" {
    # Configure your S3 backend here
    bucket               = "terraform-aws-modules-example-state"
    key                  = "hanyouqing/terraform-aws-modules:ec2/examples/jump/terraform.tfstate"
    region               = "us-east-1"
    encrypt              = true
    use_lockfile         = true
    workspace_key_prefix = "env:production"
  }
}
