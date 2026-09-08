# Terraform State Backend

Creates an S3 bucket and DynamoDB lock table for Terraform remote state, with secure defaults.

## Features

- S3 versioning, SSE (AES256 or KMS), public access block, TLS deny policy
- DynamoDB lock table
- Optional IAM user / access keys (disabled by default — prefer SSO/roles)
- `backend_config` output for Terragrunt / backend blocks

## Bootstrap order

1. Apply this module with a **local** backend (or this example).
2. Copy `backend_config` into Terragrunt `account.hcl` / root backend.
3. Migrate existing state with `terraform init -migrate-state` if needed.

## Examples

| Example | Description |
|---------|-------------|
| [basic](./examples/basic/) | Bucket + lock table only |
| [complete](./examples/complete/) | Full options; optional IAM user |

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "tfstate" {
  source = "git::https://github.com/hanyouqing/terraform-aws-modules.git//tfstate?ref=main"

  project     = "ihomelabs"
  environment = "development"
  region      = "us-east-1"

  create_iam_user       = false
  create_iam_access_key = false
}
```

## Free Tier / Cost Notes

S3 and DynamoDB incur small storage/request charges. Keep noncurrent version expiration enabled to limit cost.

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
| [aws_dynamodb_table.terraform_state_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_access_key.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name for Terraform state. Defaults to '{project}-terraform-state-{environment}' | `string` | `null` | no |
| <a name="input_code"></a> [code](#input\_code) | Code repository and path tag (e.g. 'reponame:path/to/tfstate') | `string` | `null` | no |
| <a name="input_create_iam_access_key"></a> [create\_iam\_access\_key](#input\_create\_iam\_access\_key) | Create a long-lived access key for the IAM user (requires create\_iam\_user = true) | `bool` | `false` | no |
| <a name="input_create_iam_user"></a> [create\_iam\_user](#input\_create\_iam\_user) | Create a dedicated IAM user for Terraform state access (prefer SSO/roles when false) | `bool` | `false` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | DynamoDB table name for state locking. Defaults to '{project}-terraform-state-lock-{environment}' | `string` | `null` | no |
| <a name="input_enable_lifecycle_rule"></a> [enable\_lifecycle\_rule](#input\_enable\_lifecycle\_rule) | Enable lifecycle rule for non-current object versions | `bool` | `true` | no |
| <a name="input_enable_public_access_block"></a> [enable\_public\_access\_block](#input\_enable\_public\_access\_block) | Enable S3 public access block (all four settings) | `bool` | `true` | no |
| <a name="input_enable_server_side_encryption"></a> [enable\_server\_side\_encryption](#input\_enable\_server\_side\_encryption) | Enable server-side encryption for S3 bucket | `bool` | `true` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning for S3 bucket | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID/ARN for encryption (required when sse\_algorithm is aws:kms) | `string` | `null` | no |
| <a name="input_noncurrent_version_expiration_days"></a> [noncurrent\_version\_expiration\_days](#input\_noncurrent\_version\_expiration\_days) | Days after which non-current versions are deleted | `number` | `90` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner tag for resources | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the state bucket and lock table | `string` | `"us-east-1"` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | Server-side encryption algorithm (AES256 or aws:kms) | `string` | `"AES256"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags applied to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backend_config"></a> [backend\_config](#output\_backend\_config) | Backend configuration for Terraform S3 backend |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | ARN of the DynamoDB table for state locking |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | Name of the DynamoDB table for state locking |
| <a name="output_iam_access_key_id"></a> [iam\_access\_key\_id](#output\_iam\_access\_key\_id) | Access key ID for the Terraform IAM user (null when keys are not created) |
| <a name="output_iam_secret_access_key"></a> [iam\_secret\_access\_key](#output\_iam\_secret\_access\_key) | Secret access key for the Terraform IAM user (null when keys are not created) |
| <a name="output_iam_user_arn"></a> [iam\_user\_arn](#output\_iam\_user\_arn) | ARN of the IAM user for Terraform (null when create\_iam\_user is false) |
| <a name="output_iam_user_name"></a> [iam\_user\_name](#output\_iam\_user\_name) | Name of the IAM user for Terraform (null when create\_iam\_user is false) |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket for Terraform state |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of the S3 bucket for Terraform state |
| <a name="output_zzz_reminders"></a> [zzz\_reminders](#output\_zzz\_reminders) | Operational reminders for state backend bootstrap |
<!-- END_TF_DOCS -->
