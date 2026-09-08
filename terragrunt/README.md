# Terragrunt stacks for terraform-aws-modules
#
# Hierarchy: <account>/<region>/<environment>/<module>/terragrunt.hcl
# Shared defaults: _envcommon/<module>.hcl
# Bootstrap remote state with the `tfstate` module before using S3 backend.

See [docs/terragrunt-apply.md](../docs/terragrunt-apply.md).
