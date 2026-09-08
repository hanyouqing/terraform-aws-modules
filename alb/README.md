# ALB Module

Creates an Application Load Balancer with target groups and listeners.

## Features

- Application Load Balancer with deletion protection default on
- Drop invalid headers enabled
- HTTP and HTTPS listeners
- TLS 1.3 policy default for HTTPS

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
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable deletion protection | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | Map of HTTP listeners (prefer HTTPS in production) | <pre>map(object({<br/>    port             = optional(number, 80)<br/>    target_group_key = string<br/>  }))</pre> | `{}` | no |
| <a name="input_https_listeners"></a> [https\_listeners](#input\_https\_listeners) | Map of HTTPS listeners | <pre>map(object({<br/>    port             = optional(number, 443)<br/>    certificate_arn  = string<br/>    ssl_policy       = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")<br/>    target_group_key = string<br/>  }))</pre> | `{}` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | Idle timeout seconds | `number` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether the load balancer is internal | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Load balancer name | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs for the load balancer | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for the load balancer | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | Map of target groups | <pre>map(object({<br/>    port                 = number<br/>    protocol             = optional(string, "HTTP")<br/>    target_type          = optional(string, "instance")<br/>    health_check_path    = optional(string, "/")<br/>    health_check_matcher = optional(string, "200")<br/>    deregistration_delay = optional(number, 30)<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | ALB ARN |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | ALB DNS name |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | ALB hosted zone ID |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | Map of target group ARNs |
<!-- END_TF_DOCS -->
