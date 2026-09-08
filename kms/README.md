# KMS Module

Creates AWS KMS customer managed keys for encryption at rest.

## Features

- Customer managed keys with rotation enabled by default
- Optional aliases and custom key policies
- Map/for_each API

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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_keys"></a> [keys](#input\_keys) | Map of KMS keys to create | <pre>map(object({<br/>    description             = optional(string, "Customer managed KMS key")<br/>    deletion_window_in_days = optional(number, 30)<br/>    enable_key_rotation     = optional(bool, true)<br/>    multi_region            = optional(bool, false)<br/>    alias                   = optional(string, null)<br/>    policy                  = optional(string, null)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_aliases"></a> [aliases](#output\_aliases) | Map of aliases |
| <a name="output_key_arns"></a> [key\_arns](#output\_key\_arns) | Map of key ARNs |
| <a name="output_key_ids"></a> [key\_ids](#output\_key\_ids) | Map of key IDs |
<!-- END_TF_DOCS -->
