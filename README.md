# Terraform AWS Modules

Production-ready Terraform modules for AWS, aligned with [`terraform-oci-modules`](https://github.com/hanyouqing/terraform-oci-modules) enterprise standards.

## Modules

### Foundation

| Module | Description |
|--------|-------------|
| **[vpc](./vpc/)** | Multi-AZ VPC (public/private/database), endpoints, flow logs, DNS/ACM |
| **[tfstate](./tfstate/)** | S3 + DynamoDB remote state (IAM user/keys optional) |
| **[organizations](./organizations/)** | Accounts, OUs, SCPs |

### Compute & networking

| Module | Description |
|--------|-------------|
| **[ec2](./ec2/)** | EC2 (+ optional JumpServer/GitLab/Netbird, ASG/ALB); least-privilege IAM |
| **[eks](./eks/)** | EKS cluster + managed node group (private API preferred) |
| **[ecs](./ecs/)** | ECS cluster with Fargate capacity providers |
| **[alb](./alb/)** | Application Load Balancer, target groups, listeners |
| **[iam-role](./iam-role/)** | IAM roles, managed/inline policies, instance profiles |

### Data & containers

| Module | Description |
|--------|-------------|
| **[s3](./s3/)** | Private encrypted buckets (map API) |
| **[rds](./rds/)** | PostgreSQL/MySQL/MariaDB with secure defaults |
| **[ecr](./ecr/)** | Container registries (immutable + scan-on-push) |

### Security & ops

| Module | Description |
|--------|-------------|
| **[kms](./kms/)** | Customer managed keys (rotation on) |
| **[secrets-manager](./secrets-manager/)** | Secrets (inject values via CI, not git) |
| **[sns](./sns/)** | Notification topics + subscriptions |
| **[cloudwatch](./cloudwatch/)** | Log groups + metric alarms |

Standards: **[GEMINI.md](./GEMINI.md)**. Pre-release review: **[docs/REVIEW_REPORT.md](./docs/REVIEW_REPORT.md)**.

## Quick Start

```bash
cp .env.sh.example .env.sh && source .env.sh
export TF_CLI_CONFIG_FILE="$(pwd)/.terraformrc"
mkdir -p ~/.terraform.d/plugin-cache

make help
make fmt validate-modules docs
```

### Terragrunt

```bash
# Bootstrap state once
cd tfstate/examples/basic && terraform init && terraform apply

# Configure terragrunt/personal/account.hcl, then:
cd terragrunt/personal/us-east-1/development/vpc && terragrunt plan
```

## Prerequisites

- Terraform `>= 1.14.2`
- AWS provider `~> 6.28`
- AWS CLI (SSO recommended)
- Optional: Terragrunt `>= 0.55`, tflint, tfsec, terraform-docs

## Quality Gate

```bash
make pre-commit
make ci
```

CI: [.github/workflows/ci.yml](./.github/workflows/ci.yml)

## Hard Rules

1. Modules never configure `provider "aws"`.
2. Every module ships `examples/basic` and `examples/complete`.
3. Secure-by-default; no world-open SG defaults unless explicitly public.
4. Commit `make docs` output (inject markers).

## License

Apache License 2.0 — see [LICENSE](./LICENSE).
