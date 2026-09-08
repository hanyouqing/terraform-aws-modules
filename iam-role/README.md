# IAM Role Module

Creates IAM roles for services and workloads.

## Features

- Map of roles with managed + inline policies
- Optional instance profiles
- Permissions boundary support
- No embedded credentials

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
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | Map of IAM roles to create | <pre>map(object({<br/>    name                    = optional(string, null)<br/>    path                    = optional(string, "/")<br/>    description             = optional(string, "")<br/>    assume_role_policy      = string<br/>    max_session_duration    = optional(number, 3600)<br/>    permissions_boundary    = optional(string, null)<br/>    managed_policy_arns     = optional(list(string), [])<br/>    inline_policies         = optional(map(string), {})<br/>    create_instance_profile = optional(bool, false)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instance_profile_arns"></a> [instance\_profile\_arns](#output\_instance\_profile\_arns) | Map of instance profile ARNs |
| <a name="output_role_arns"></a> [role\_arns](#output\_role\_arns) | Map of role ARNs |
| <a name="output_role_names"></a> [role\_names](#output\_role\_names) | Map of role names |
<!-- END_TF_DOCS -->
