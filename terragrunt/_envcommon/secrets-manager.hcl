locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env         = local.env_vars.locals.environment
  project     = local.env_vars.locals.project
  region      = local.region_vars.locals.region
}

terraform {
  source = "${dirname(find_in_parent_folders(\"root.hcl\"))}/../secrets-manager"
}

inputs = {
  project     = local.project
  environment = local.env
}
