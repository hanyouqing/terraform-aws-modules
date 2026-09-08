# AWS Organizations Module

Manages AWS Organizations accounts, organizational units (OUs), and service control policies (SCPs).

## Features

- Create and tag member accounts (optional `parent_id` for OU placement)
- Create nested OUs
- Create and attach SCPs
- No provider configuration inside the module (Terragrunt / caller owns auth)

## Prerequisites

- Run from the management (payer) account
- Organizations already enabled
- Unique email per new account

## Examples

| Example | Description |
|---------|-------------|
| [basic](./examples/basic/) | Minimal OU creation |
| [identity-main-accounts](./examples/identity-main-accounts/) | Multi-stack identity pattern |

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "organizations" {
  source = "git::https://github.com/hanyouqing/terraform-aws-modules.git//organizations?ref=main"

  project     = "ihomelabs"
  environment = "production"

  accounts = [
    {
      name  = "workload-dev"
      email = "aws-dev+workload-dev@example.com"
      # parent_id = module.organizations.organizational_units["Workloads"].id  # after OU exists
    }
  ]

  organizational_units = [
    {
      name = "Workloads"
    }
  ]
}
```

Authenticate with AWS SSO or assume-role at the caller — never pass access keys into this module.

## Free Tier / Cost Notes

AWS Organizations itself has no additional charge; member accounts incur normal AWS usage.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_organizations_account.accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organizational_unit.ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy.scps](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.scp_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_organization.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_accounts"></a> [accounts](#input\_accounts) | List of AWS accounts to create | <pre>list(object({<br/>    name                       = string<br/>    email                      = string<br/>    parent_id                  = optional(string, null)<br/>    iam_user_access_to_billing = optional(string, "ALLOW")<br/>    role_name                  = optional(string, "OrganizationAccountAccessRole")<br/>    close_on_deletion          = optional(bool, false)<br/>    tags                       = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | List of organizational units (OUs) to create | <pre>list(object({<br/>    name      = string<br/>    parent_id = optional(string, null)<br/>    tags      = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_service_control_policies"></a> [service\_control\_policies](#input\_service\_control\_policies) | List of service control policies (SCPs) to create and attach | <pre>list(object({<br/>    name        = string<br/>    description = optional(string, "")<br/>    content     = string<br/>    type        = optional(string, "SERVICE_CONTROL_POLICY")<br/>    targets     = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all organization resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_accounts"></a> [accounts](#output\_accounts) | Created AWS accounts |
| <a name="output_master_account_email"></a> [master\_account\_email](#output\_master\_account\_email) | AWS Organizations master account email |
| <a name="output_master_account_id"></a> [master\_account\_id](#output\_master\_account\_id) | AWS Organizations master account ID |
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | AWS Organizations organization ARN |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | AWS Organizations organization ID |
| <a name="output_organizational_units"></a> [organizational\_units](#output\_organizational\_units) | Created organizational units |
| <a name="output_service_control_policies"></a> [service\_control\_policies](#output\_service\_control\_policies) | Created service control policies |
<!-- END_TF_DOCS -->
