region = "us-east-1"

project     = "vpc-basic"
environment = "development"

vpc_cidr = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

enable_nat_gateway = true
single_nat_gateway = true

enable_flow_log = true

tags = {
  Owner      = "DevOps"
  CostCenter = "Infrastructure"
  Code       = "terraform-aws-modules:vpc/examples/basic"
}
