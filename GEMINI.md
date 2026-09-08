# GEMINI.md - Project Guidelines & Standards

This document defines the standards, conventions, and workflows for the `terraform-aws-modules` project. All changes and new modules must adhere to these guidelines. Patterns mirror `terraform-oci-modules` with AWS-specific adaptations.

## 1. Project Objective

Create a suite of **production-ready**, **secure**, and **cost-aware** Terraform modules for Amazon Web Services (AWS).

- **Production-Ready**: High availability, security hardening, monitoring, and robust error handling.
- **Free Tier / Cost Aware**: Prefer cost-optimized defaults for non-production; document Free Tier and cost implications in module READMEs.
- **Terragrunt Friendly**: Clean inputs/outputs; **no `provider` blocks inside modules**.

## 2. Module Structure

Each module must follow this directory structure:

```text
module-name/
├── main.tf             # Core resources (or thin entry; domain split files OK)
├── variables.tf        # Input variables (descriptions & types required)
├── outputs.tf          # Outputs (descriptions required)
├── versions.tf         # Provider & Terraform version constraints ONLY
├── data.tf / locals.tf # Optional when size warrants
├── README.md           # Hand-written header + terraform-docs inject markers
└── examples/
    ├── basic/          # Minimal / secure / cost-aware
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── complete/       # Production-oriented full features
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── (optional scenario examples)
```

**Hard rules**

- Modules **never** configure `provider "aws"` — callers / Terragrunt generate providers.
- Every module has `versions.tf`, `variables.tf`, `outputs.tf`, `README.md`, and `examples/{basic,complete}/`.
- Domain-split files (`vpc.tf`, `security_groups.tf`, …) are allowed when modules grow large.

## 3. Coding Standards

### Naming

- Resources/data: `snake_case`. Primary resource may be named `this` or a clear noun.
- Variables/outputs: descriptive `snake_case`.
- Module directories: kebab-case (`tfstate`, not `TFState`).

### Variables

- Always typed; prefer `object({...})` / `map(object)` with `optional(..., default)`. Avoid `any`.
- Description required on every variable (enforced by tflint).
- Use `validation {}` for CIDRs, ARNs, enums, lengths, cross-key refs.
- Optional/unset attributes: `default = null` (not empty string).
- Secrets: `sensitive = true`. Never commit real credentials.

### Outputs

- Expose useful IDs/ARNs/attributes with descriptions.
- Mark secrets `sensitive = true`.
- Optional operational guidance via `zzz_reminders` is allowed.

### Tagging

All taggable resources must merge module defaults with caller tags:

```hcl
tags = merge(
  {
    ManagedBy   = "terraform"
    Module      = "github.com/hanyouqing/terraform-aws-modules/<module-name>"
    Project     = var.project
    Environment = var.environment
  },
  var.tags
)
```

Every module exposes at least: `project`, `environment`, `tags`.

### for_each vs count

| Use | When |
|-----|------|
| `for_each` + map | Named multi-resources |
| `count` | Boolean create toggles; identical N instances |
| `dynamic` | Optional nested blocks |

## 4. Security Guidelines

- Security groups / NACLs: deny-by-default; no `0.0.0.0/0` in insecure defaults unless the variable is explicitly `public_*` and documented.
- Encryption at rest and in transit where configurable (S3 SSE, EBS, TLS deny policies).
- Prefer IAM roles / SSO / OIDC over long-lived access keys.
- State backend: S3 versioning + encryption + public access block + DynamoDB lock.
- Never commit secrets; `.tfvars` / `.env.sh` are gitignored.
- Modules must be scannable with tfsec/checkov; suppress only with justified comments.

## 5. Documentation

- README hand-written sections: Features, Free Tier / cost notes, Examples table, Usage.
- Auto sections via terraform-docs between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->`.
- CI fails on docs drift (`make docs` must be committed).

## 6. Implementation Workflow

1. Analyze AWS resource constraints and IAM.
2. Scaffold module structure.
3. Implement with secure defaults.
4. Add `examples/basic` and `examples/complete`.
5. `terraform fmt` / `validate` / `tflint` / `tfsec`.
6. Run `make docs`.

## 7. Versioning

Keep these in sync across root README, Makefile, CI, `.terraform-version`, and every `versions.tf`:

- **Terraform**: `>= 1.14.2` (`.terraform-version` = `1.14.2`)
- **AWS provider**: `~> 6.28`
- **Terragrunt** (docs/CI): `>= 0.55`

## 8. Terragrunt

- Hierarchy: `terragrunt/<account>/<region>/<environment>/<module>/terragrunt.hcl`
- Layers: `account.hcl` → `region.hcl` → `env.hcl` + `_envcommon/<module>.hcl`
- `root.hcl` generates S3 backend + `provider "aws"`; modules keep constraints only in `versions.tf`
- Use `dependency` blocks with `mock_outputs` for plan/validate

## 9. Module-Specific Notes

### vpc

- Multi-AZ public/private/database tiers; secure SG/NACL defaults; optional flow logs/endpoints.

### ec2

- IMDSv2 on; EBS encryption preferred; prefer SSM over public SSH; no embedded provider.

### tfstate

- Bootstrap S3 + DynamoDB; IAM user/access keys optional (prefer roles); document import/bootstrap flow.

### s3 / kms / ecr / rds / alb / iam-role / sns / cloudwatch / secrets-manager

- Prefer map + `for_each` APIs.
- Encryption, private access, and deletion protection on by default where applicable.

### organizations

- Manage accounts/OUs/SCPs; no credential variables; caller authenticates via env/SSO/assume-role.

---

**Conflict resolution**: When ease-of-use conflicts with security (especially in `basic` examples), prioritize security (e.g., require caller IP allowlists rather than opening to the world).
