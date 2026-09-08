locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env     = local.env_vars.locals.environment
  project = local.env_vars.locals.project
  region  = local.region_vars.locals.region
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../vpc"
}

inputs = {
  project     = local.project
  environment = local.env
  region      = local.region

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${local.region}a", "${local.region}b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets   = []

  enable_nat_gateway = false
  single_nat_gateway = true
  enable_flow_log    = false
}
