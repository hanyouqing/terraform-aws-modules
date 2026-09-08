# SNS Module

Creates Amazon SNS topics for notifications and fan-out.

## Features

- Map of topics with optional subscriptions
- Optional CMK encryption
- FIFO topic support

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
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Map of SNS topics | <pre>map(object({<br/>    name                        = optional(string, null)<br/>    kms_master_key_id           = optional(string, null)<br/>    display_name                = optional(string, null)<br/>    fifo_topic                  = optional(bool, false)<br/>    content_based_deduplication = optional(bool, false)<br/>    subscriptions = optional(list(object({<br/>      protocol = string<br/>      endpoint = string<br/>    })), [])<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_topic_arns"></a> [topic\_arns](#output\_topic\_arns) | Map of topic ARNs |
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | Map of topic names |
<!-- END_TF_DOCS -->
