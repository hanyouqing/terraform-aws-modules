locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env     = local.env_vars.locals.environment
  project = local.env_vars.locals.project
  region  = local.region_vars.locals.region
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../ec2"
}

inputs = {
  project     = local.project
  environment = local.env
  region      = local.region

  # Prefer wiring subnet/SG via dependency outputs in the leaf terragrunt.hcl.
  instance_count = 1
}
