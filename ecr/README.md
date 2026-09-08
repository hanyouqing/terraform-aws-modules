# ECR Module

Creates Amazon ECR repositories with secure defaults for container images.

## Features

- Immutable tags by default
- Scan on push enabled
- Lifecycle keep-last-N images
- AES256 or KMS encryption

## Examples

| Example | Description |
|---------|-------------|
| [basic](./examples/basic/) | Minimal secure setup |
| [complete](./examples/complete/) | Production-oriented options |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.28 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Map of ECR repositories | <pre>map(object({<br/>    name                       = optional(string, null)<br/>    image_tag_mutability       = optional(string, "IMMUTABLE")<br/>    scan_on_push               = optional(bool, true)<br/>    encryption_type            = optional(string, "AES256")<br/>    kms_key_arn                = optional(string, null)<br/>    force_delete               = optional(bool, false)<br/>    lifecycle_keep_last_images = optional(number, 30)<br/>    enable_lifecycle_policy    = optional(bool, true)<br/>    tags                       = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_registry_ids"></a> [registry\_ids](#output\_registry\_ids) | Map of registry IDs |
| <a name="output_repository_arns"></a> [repository\_arns](#output\_repository\_arns) | Map of repository ARNs |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of repository URLs |
<!-- END_TF_DOCS -->
