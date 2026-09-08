include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/tfstate.hcl"
  expose         = true
  merge_strategy = "deep"
}

# Bootstrap tip: first apply with a local backend, then migrate state into this S3 backend.
inputs = {}
