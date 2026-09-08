# Secrets Manager Module

Manages AWS Secrets Manager secrets. **Do not commit secret values.** Inject `secret_string` / `secret_key_value` via `TF_VAR_secrets` or CI secrets only.

## Features

- Map of secrets with optional versions
- KMS CMK support
- 30-day recovery window by default
- Sensitive variable marking

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
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of Secrets Manager secrets. Prefer generating values outside Terraform when possible. | <pre>map(object({<br/>    name                    = optional(string, null)<br/>    description             = optional(string, "")<br/>    kms_key_id              = optional(string, null)<br/>    recovery_window_in_days = optional(number, 30)<br/>    secret_string           = optional(string, null)<br/>    secret_key_value        = optional(map(string), null)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns) | Map of secret ARNs |
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | Map of secret IDs/names |
<!-- END_TF_DOCS -->
