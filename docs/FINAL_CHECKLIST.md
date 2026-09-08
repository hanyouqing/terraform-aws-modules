# Final Checklist - Production Readiness

Use this checklist when adding or updating modules.

## Code quality

- [ ] `terraform fmt -recursive` clean
- [ ] `terraform validate` for module + examples
- [ ] `tflint --config .tflint.hcl` clean for the module
- [ ] `make security` reviewed (tfsec/checkov)

## Versions

- [ ] `required_version = ">= 1.14.2"`
- [ ] AWS provider `~> 6.28` (and any other providers pinned)
- [ ] Examples use the same pins

## Structure

- [ ] `versions.tf` only — **no** `provider` block in the module
- [ ] `variables.tf` / `outputs.tf` / `README.md`
- [ ] `examples/basic` and `examples/complete` with `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
- [ ] Docs inject markers present; `make docs` committed

## Variables / security

- [ ] Typed variables with descriptions
- [ ] Validations for enums / CIDRs / ARNs where applicable
- [ ] Secure defaults (closed SG, encryption on, no public state)
- [ ] Sensitive inputs/outputs marked
- [ ] Tags include ManagedBy / Module / Project / Environment

## Terragrunt (if applicable)

- [ ] `_envcommon/<module>.hcl` added
- [ ] Leaf `terragrunt.hcl` under account/region/env with dependency mocks as needed

## Docs honesty

- [ ] Root README lists only modules that exist
- [ ] Module README Features section accurate
