# Basic tfstate bootstrap (no IAM user / access keys)

Creates an encrypted, versioned S3 bucket and DynamoDB lock table. Authenticate with SSO or a role.

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```

After apply, point Terragrunt `account.hcl` at the bucket and table names.
