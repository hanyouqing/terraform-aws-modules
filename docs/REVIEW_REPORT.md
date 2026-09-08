# Pre-release review report

Date: 2026-09-09 (release gate)

## Scope

All 13 modules: vpc, ec2, organizations, tfstate, s3, kms, secrets-manager, ecr, iam-role, rds, alb, sns, cloudwatch.

## Blockers fixed before push

| Severity | Issue | Fix |
|----------|-------|-----|
| P0 | Tracked `terraform.tfvars` under vpc examples | Removed from git index (gitignored) |
| P0 | Tracked `terraform-plan-output.md` | Removed from git; gitignored |
| P0 | `identity-account` used role resource attrs for `target_role_name` / `external_id` | Use `var.team_roles[each.key]` |
| P1 | Personal `hanyouqing` / `web3` / `aws.hanyouqing.com` defaults in examples | Replaced with placeholders (`ACCOUNT/...`, `example.com`, `ihomelabs`) |
| P1 | EC2 ALB/ELB SG hard-coded `0.0.0.0/0` | Configurable `alb_ingress_cidr_blocks` / `elb_ingress_cidr_blocks` |
| P1 | Modules embedding providers / always-on access keys | Fixed in prior pass |
| P1 | EC2 required VPC remote state | Optional direct `vpc_id` + subnets |

## Remaining accepted risks

| Severity | Issue | Guidance |
|----------|-------|----------|
| P2 | EC2 IAM Describe* still often `Resource = "*"` | AWS API limitation for many Describe calls; continue least-privilege pass |
| P2 | Public LB default CIDR still `0.0.0.0/0` | Override with allowlists in production |
| P2 | No EKS/ECS/Lambda/SQS yet | Follow-up modules |

## Release gate

- Modules never configure `provider "aws"` (examples only)
- Secure defaults documented in module READMEs
- Terragrunt `_envcommon` present for all modules
- Docs inject markers present
