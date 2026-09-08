# Account-level configuration.
#
# Read by root.hcl via find_in_parent_folders("account.hcl").
# Replace REPLACE_ME values or set TF_VAR_* / env overrides.

locals {
  account_name    = get_env("TF_VAR_account_name", "personal")
  account_id      = get_env("TF_VAR_aws_account_id", "000000000000")
  aws_profile     = get_env("AWS_PROFILE", "default")
  project_prefix  = get_env("TF_VAR_project", "ihomelabs")
  # Created once by the tfstate module (bootstrap with local backend first).
  state_bucket     = get_env("TF_BACKEND_BUCKET", "${local.project_prefix}-terraform-state-development")
  state_lock_table = get_env("TF_BACKEND_DYNAMODB_TABLE", "${local.project_prefix}-terraform-state-lock-development")
}
