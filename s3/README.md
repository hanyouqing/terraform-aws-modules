# S3 Module

Creates private, versioned, encrypted S3 buckets with TLS-only bucket policies.

## Features

- Map/`for_each` multi-bucket API
- Versioning, SSE (AES256/KMS), public access block, ownership controls
- Optional lifecycle for noncurrent versions and access logging
- Deny non-TLS access by default

## Examples

| Example | Description |
|---------|-------------|
| [basic](./examples/basic/) | Single app bucket |
| [complete](./examples/complete/) | KMS + logging options |

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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.tls_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | Map of S3 buckets to create. Secure defaults: private, versioned, encrypted. | <pre>map(object({<br/>    bucket_prefix             = optional(string, null)<br/>    bucket                    = optional(string, null)<br/>    force_destroy             = optional(bool, false)<br/>    versioning_enabled        = optional(bool, true)<br/>    sse_algorithm             = optional(string, "AES256")<br/>    kms_key_id                = optional(string, null)<br/>    bucket_key_enabled        = optional(bool, true)<br/>    block_public_acls         = optional(bool, true)<br/>    block_public_policy       = optional(bool, true)<br/>    ignore_public_acls        = optional(bool, true)<br/>    restrict_public_buckets   = optional(bool, true)<br/>    object_ownership          = optional(string, "BucketOwnerEnforced")<br/>    lifecycle_noncurrent_days = optional(number, 90)<br/>    enable_lifecycle          = optional(bool, true)<br/>    enable_access_logging     = optional(bool, false)<br/>    access_log_bucket         = optional(string, null)<br/>    access_log_prefix         = optional(string, "s3-access/")<br/>    tags                      = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (development, testing, staging, production) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used in default tags | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags merged into all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_arns"></a> [bucket\_arns](#output\_bucket\_arns) | Map of bucket keys to bucket ARNs |
| <a name="output_bucket_domain_names"></a> [bucket\_domain\_names](#output\_bucket\_domain\_names) | Map of bucket keys to domain names |
| <a name="output_bucket_ids"></a> [bucket\_ids](#output\_bucket\_ids) | Map of bucket keys to bucket IDs |
<!-- END_TF_DOCS -->
