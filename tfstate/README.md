# Terraform State Backend Infrastructure

This module creates the necessary AWS infrastructure for storing Terraform state remotely:
- S3 bucket for state storage
- DynamoDB table for state locking
- IAM user with appropriate permissions

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform ~> 1.14 installed
- AWS account with permissions to create S3 buckets, DynamoDB tables, and IAM resources

## Usage

1. Copy the example tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Update `terraform.tfvars` with your values

3. Initialize Terraform:
```bash
terraform init
```

4. Review the plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

6. After applying, retrieve the IAM user credentials:
```bash
terraform output -json
```

**Important**: Save the `iam_access_key_id` and `iam_secret_access_key` securely. These credentials will be used by Terraform to access the state bucket.

## Configuration

### Variables

- `environment`: Environment name (testing, staging, production)
- `project`: Project name (default: "web3")
- `region`: AWS region (default: "us-east-1")
- `bucket_name`: Optional custom S3 bucket name
- `dynamodb_table_name`: Optional custom DynamoDB table name
- `enable_versioning`: Enable S3 versioning (default: true)
- `enable_server_side_encryption`: Enable encryption (default: true)
- `sse_algorithm`: Encryption algorithm - AES256 or aws:kms (default: AES256)
- `kms_key_id`: KMS key ID (required if using aws:kms)
- `enable_lifecycle_rule`: Enable lifecycle rule for old versions (default: true)
- `noncurrent_version_expiration_days`: Days before deleting old versions (default: 90)
- `enable_public_access_block`: Block public access (default: true)

### Outputs

- `s3_bucket_name`: S3 bucket name for state storage
- `s3_bucket_arn`: S3 bucket ARN
- `dynamodb_table_name`: DynamoDB table name for locking
- `dynamodb_table_arn`: DynamoDB table ARN
- `iam_user_name`: IAM user name
- `iam_user_arn`: IAM user ARN
- `iam_access_key_id`: Access key ID (sensitive)
- `iam_secret_access_key`: Secret access key (sensitive)
- `backend_config`: Backend configuration object

## Using the Backend

After creating the infrastructure, configure your Terraform projects to use this backend:

1. Create a `backend.tf` file in your Terraform project:
```hcl
terraform {
  backend "s3" {
    bucket         = "web3-terraform-state-production"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "web3-terraform-state-lock-production"
  }
}
```

2. Initialize with the backend:
```bash
terraform init -migrate-state
```

## Security Best Practices

- The S3 bucket enforces encryption in transit (TLS 1.2+)
- Public access is blocked by default
- Versioning is enabled for state recovery
- Lifecycle rules automatically clean up old versions
- IAM user follows least privilege principles

## Cost Considerations

- S3 storage: ~$0.023 per GB/month
- DynamoDB: Pay-per-request pricing (very low cost for state locking)
- Estimated monthly cost: < $1 for typical usage

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

**Warning**: This will delete the state bucket and all state files. Ensure you have backups before destroying.

