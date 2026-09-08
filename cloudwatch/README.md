# CloudWatch Module

Creates CloudWatch log groups and metric alarms.

## Features

- Log groups with retention defaults
- Optional KMS encryption on log groups
- Metric alarms with SNS action hooks

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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_log_groups"></a> [log\_groups](#input\_log\_groups) | Map of CloudWatch log groups | <pre>map(object({<br/>    name              = optional(string, null)<br/>    retention_in_days = optional(number, 30)<br/>    kms_key_id        = optional(string, null)<br/>    tags              = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_metric_alarms"></a> [metric\_alarms](#input\_metric\_alarms) | Map of CloudWatch metric alarms | <pre>map(object({<br/>    alarm_name          = optional(string, null)<br/>    comparison_operator = string<br/>    evaluation_periods  = number<br/>    metric_name         = string<br/>    namespace           = string<br/>    period              = number<br/>    statistic           = string<br/>    threshold           = number<br/>    alarm_description   = optional(string, null)<br/>    alarm_actions       = optional(list(string), [])<br/>    ok_actions          = optional(list(string), [])<br/>    treat_missing_data  = optional(string, "notBreaching")<br/>    dimensions          = optional(map(string), {})<br/>    tags                = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | Map of alarm ARNs |
| <a name="output_log_group_arns"></a> [log\_group\_arns](#output\_log\_group\_arns) | Map of log group ARNs |
| <a name="output_log_group_names"></a> [log\_group\_names](#output\_log\_group\_names) | Map of log group names |
<!-- END_TF_DOCS -->
