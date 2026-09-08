# Configuration Files Guide

Development tool configuration for this repository. For secrets and state, see [SECURITY.md](SECURITY.md).

## TFLint — `.tflint.hcl`

```bash
make lint-init
make lint
make lint-module MODULE=vpc
```

- Terraform recommended preset + AWS ruleset plugin
- Enforces documented variables/outputs, typed variables, naming, required_version/providers

## TFSec — `.tfsec.yml`

```bash
make tfsec
# or
make security
```

- Minimum severity: LOW
- Examples and `.terraform` excluded
- Prefer fixing findings over `# tfsec:ignore`

## Terraform Docs — `.terraform-docs.yml`

```bash
make docs
make docs-module MODULE=vpc
```

- Inject mode into each module `README.md` between `<!-- BEGIN_TF_DOCS -->` … `<!-- END_TF_DOCS -->`
- CI fails on docs drift

## Pre-commit — `.pre-commit-config.yaml`

```bash
pre-commit install
pre-commit run --all-files
```

Hooks: `terraform_fmt`, `terraform_validate`, `terraform_docs`, `terraform_tflint`

## Terraform CLI — `.terraformrc`

```bash
cp .terraformrc.example .terraformrc   # or use committed .terraformrc
export TF_CLI_CONFIG_FILE="$(pwd)/.terraformrc"
mkdir -p ~/.terraform.d/plugin-cache
```

- `plugin_cache_dir = "~/.terraform.d/plugin-cache"` (tilde required; `$HOME` is not expanded)

## Version pins

| Tool | Pin |
|------|-----|
| Terraform | `1.14.2` (`.terraform-version`) / `>= 1.14.2` in modules |
| AWS provider | `~> 6.28` |
| terraform-docs (CI) | `v0.19.0` |
