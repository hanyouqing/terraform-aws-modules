# Security practices for this repository

How this project avoids storing **passwords, API keys, tokens, and other secrets** in version control, and how to handle them safely with Terraform and AWS.

## What must not be committed

| Item | Why | Mitigation |
|------|-----|------------|
| **Terraform state** (`.tfstate`) | Often contains secrets and identifiers | Listed in `.gitignore`; use S3 backend with encryption, public access block, and DynamoDB locking (`tfstate` module) |
| **`.tfvars` / `*.tfvars.json`** | Typical place for secrets | Ignored by `.gitignore`; use `*.tfvars.example` templates only |
| **`.env.sh`, `.env`** | AWS keys, session tokens | Ignored; use `.env.sh.example` |
| **Private keys** (`*.pem`, SSH keys) | Access material | Keep outside the repo; `*.pem` ignored |
| **Terraform plan files** | Can echo sensitive values | Ignore `*.tfplan` |
| **Long-lived IAM access keys in modules** | Credential sprawl | Prefer SSO / assume-role / OIDC; `tfstate` creates keys only when explicitly enabled |

## Environment variables

- Prefer **AWS SSO** (`aws sso login`) or IAM roles over static keys.
- Pass sensitive inputs via `TF_VAR_*` from CI secret stores—never commit real values.
- Terragrunt S3 backend and the AWS provider should share the same credential chain (profile / env / instance role).

## Terraform: `sensitive` variables

Variables and outputs that carry secrets use `sensitive = true`. **State may still store secret values**—protect the backend and restrict IAM.

## Code review checklist

1. No new `*.tfvars` with real secrets checked in.
2. No real account IDs / keys / emails in examples beyond placeholders.
3. No `provider "aws"` blocks inside reusable modules.
4. CI injects secrets from the platform secret store.

## Tools in this repo

- **TFSec / Checkov** (`make security`)
- **`.tfsec.yml`** — exclusions and severity
- **TFLint AWS ruleset** — `.tflint.hcl`

See also [AWS security best practices](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html) and [Terraform AWS provider auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).
