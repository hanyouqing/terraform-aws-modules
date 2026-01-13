# S3 Backend Configuration
# 
# Before using this backend, ensure the S3 bucket exists:
#   aws s3 mb s3://terraform-state-for-aws-modules-example --region us-east-1
#   aws s3api put-bucket-versioning --bucket terraform-state-for-aws-modules-example --versioning-configuration Status=Enabled
#   aws s3api put-bucket-encryption --bucket terraform-state-for-aws-modules-example --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
#
# Alternatively, use the tfstate module to create the backend infrastructure:
#   cd ../../tfstate && terraform apply
#
# To use local state for development, comment out this backend block.

terraform {
  backend "s3" {
    bucket         = "terraform-state-for-terraform-aws-modules-example"
    key            = "hanyouqing/terraform-aws-modules:vpc/examples/complete/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
