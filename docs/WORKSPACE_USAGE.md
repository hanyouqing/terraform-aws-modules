# Workspace usage

Manage Terraform workspaces for `development`, `testing`, `staging`, and `production`.

## Wrapper

```bash
./terraform-wrapper.sh -e development plan
./terraform-wrapper.sh -e production apply
```

## Direct script

```bash
./scripts/terraform-workspace.sh -e development
terraform plan
```

## Rules

- Always select the correct workspace before plan/apply when not using Terragrunt.
- Prefer Terragrunt env directories (`terragrunt/<account>/<region>/<env>/...`) for multi-env stacks; workspaces are optional for simple local runs.
- Never apply production from a development workspace by accident—verify with `terraform workspace show`.
