# Terragrunt apply guide

## Layout

```text
terragrunt/
├── root.hcl
├── _envcommon/          # shared module defaults
└── <account>/
    ├── account.hcl
    └── <region>/
        ├── region.hcl
        └── <environment>/
            ├── env.hcl
            └── <module>/terragrunt.hcl
```

## Bootstrap order

1. Create/configure AWS credentials (SSO recommended).
2. Bootstrap remote state once with the `tfstate` module (local backend is fine for bootstrap).
3. Put bucket/table names into `account.hcl` / env vars used by `root.hcl`.
4. Apply stacks in dependency order (e.g. `vpc` before `ec2`).

## Commands

```bash
cd terragrunt/personal/us-east-1/development/vpc
terragrunt init
terragrunt plan
terragrunt apply
```

## Notes

- Modules do not embed providers; Terragrunt generates `provider_tg.tf` and `backend.tf`.
- `disable_dependency_optimization = true` so `mock_outputs` work for plan/validate.
- Pin `terraform.source` to a git ref for production; local relative paths are fine for development.
