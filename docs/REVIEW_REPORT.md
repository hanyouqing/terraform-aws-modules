# Pre-release review report

Date: 2026-09-09 (follow-up)

## Completed follow-ups

| Item | Change |
|------|--------|
| EC2 IAM least privilege | Scoped Secrets/ECR/EKS/ECS/KMS/Logs; ECR pull-only and ECS mutations off by default; Describe* kept on `*` only where AWS requires it |
| LB public CIDR | `alb_ingress_cidr_blocks` / `elb_ingress_cidr_blocks` default `[]` (must set); production blocks `0.0.0.0/0` unless `allow_public_lb_ingress = true` |
| EKS / ECS modules | Added with examples, docs inject, Terragrunt `_envcommon` |

## Module count

15 modules: vpc, ec2, eks, ecs, organizations, tfstate, s3, kms, secrets-manager, ecr, iam-role, rds, alb, sns, cloudwatch.

## Remaining optional hardening

- Attach IRSA OIDC provider resources in `eks` (addon/IRSA helpers)
- ECS service/task definition submodule
- Further EC2 IAM Condition keys for Describe* where AWS adds support
