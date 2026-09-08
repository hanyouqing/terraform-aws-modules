# Terraform plan usage

## Local module / example

```bash
cd vpc/examples/basic
cp terraform.tfvars.example terraform.tfvars   # edit placeholders
terraform init -backend=false                  # or configure S3 backend
terraform plan -out=tfplan
terraform show -no-color tfplan
```

## Makefile

```bash
make plan-example EXAMPLE=vpc/examples/basic
```

## Terragrunt

```bash
cd terragrunt/personal/us-east-1/development/vpc
terragrunt plan
```

## Production habits

1. Always review plan before apply.
2. Prefer saved plans (`-out=`) for apply in CI.
3. Do not commit plan files (they may contain sensitive values).
4. Use `TF_IN_AUTOMATION=true` in CI.
