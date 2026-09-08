include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/ec2.hcl"
  expose         = true
  merge_strategy = "deep"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    vpc_id             = "vpc-mock"
    public_subnet_ids  = ["subnet-mock-a", "subnet-mock-b"]
    private_subnet_ids = ["subnet-mock-priv-a", "subnet-mock-priv-b"]
  }
}

inputs = {
  # Override with real remote-state / input wiring required by the ec2 module.
  # Example placeholders — adjust to your module's variable names:
  # subnet_ids = dependency.vpc.outputs.public_subnet_ids
}
