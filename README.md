# Terraform AWS Modules

A collection of production-ready Terraform modules for AWS infrastructure.

## Modules

- **[VPC](./vpc/)**: Complete VPC setup with public, private, and database subnets
- **[EC2](./ec2/)**: EC2 jump server (bastion host) with optional JumpServer installation
- **[EKS](./eks/)**: Amazon EKS cluster with node groups and addons
- **[SSO](./sso/)**: AWS IAM Identity Center (SSO) configuration
- **[Organizations](./organizations/)**: AWS Organizations management
- **[Lightsail](./lightsail/)**: AWS Lightsail container and database services
- **[TFState](./tfstate/)**: Terraform state backend (S3 + DynamoDB)

## Quick Start

### 1. Configure Environment Variables

Copy and configure the environment variables file:

```bash
cp .env.sh.example .env.sh
# Edit .env.sh with your specific values
source .env.sh
```

### 2. Configure Terraform CLI (Optional)

Copy and configure the Terraform CLI configuration:

```bash
cp .terraformrc.example .terraformrc
# Edit .terraformrc if needed (usually defaults are fine)
```

### 3. Use Makefile (Recommended)

The project includes a comprehensive Makefile with common tasks:

```bash
# Show all available commands
make help

# Format all Terraform files
make fmt

# Validate all modules
make validate-modules

# Run linting
make lint

# Run security scans
make security

# Generate documentation
make docs
```

### 4. Use a Module

Navigate to a module's example directory:

```bash
cd vpc/examples/basic
# or
cd ec2/examples/complete
```

### 5. Initialize and Apply

```bash
# Using Makefile
make init
make plan
make apply

# Or using Terraform directly
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Terraform >= 1.14.2
- AWS CLI configured with appropriate credentials
- AWS Provider ~> 6.28

## Environment Variables

See [.env.sh.example](./.env.sh.example) for all available environment variables.

Key variables:
- `AWS_DEFAULT_REGION`: AWS region (default: us-east-1)
- `TF_BACKEND_BUCKET`: S3 bucket for Terraform state
- `TF_VAR_project`: Project name
- `TF_VAR_environment`: Environment (development, testing, staging, production)

## Terraform Configuration

See [.terraformrc](./.terraformrc) for Terraform CLI configuration options.

## Makefile Commands

The project includes a comprehensive Makefile with the following categories:

### Formatting
- `make fmt` - Format all Terraform files
- `make fmt-check` - Check if files are formatted
- `make fmt-module MODULE=vpc` - Format a specific module
- `make fmt-example EXAMPLE=vpc/examples/basic` - Format a specific example

### Validation
- `make validate` - Validate all modules and examples
- `make validate-modules` - Validate all modules
- `make validate-examples` - Validate all examples
- `make validate-module MODULE=vpc` - Validate a specific module

### Linting
- `make lint` - Run tflint on all modules
- `make lint-module MODULE=vpc` - Lint a specific module

### Security
- `make security` - Run security scans (tfsec and checkov)
- `make tfsec` - Run tfsec security scanner
- `make checkov` - Run checkov security scanner

### Documentation
- `make docs` - Generate documentation for all modules
- `make docs-module MODULE=vpc` - Generate docs for a specific module

### Terraform Operations
- `make init` - Initialize Terraform in current directory
- `make init-module MODULE=vpc` - Initialize a specific module
- `make init-example EXAMPLE=vpc/examples/basic` - Initialize a specific example
- `make plan` - Run terraform plan
- `make plan-example EXAMPLE=vpc/examples/basic` - Plan a specific example
- `make apply` - Run terraform apply (with confirmation)

### Cleanup
- `make clean` - Clean all Terraform files (.terraform, .tfstate, etc.)
- `make clean-module MODULE=vpc` - Clean a specific module
- `make clean-example EXAMPLE=vpc/examples/basic` - Clean a specific example

### Information
- `make list-modules` - List all modules
- `make list-examples` - List all examples
- `make info` - Show project information
- `make check-versions` - Check tool versions

### CI/CD
- `make pre-commit` - Run pre-commit checks (fmt-check, validate-modules, lint)
- `make ci` - Run full CI checks (fmt-check, validate, lint, security)

### Tool Installation
- `make install-tools` - Install all recommended tools
- `make install-terraform-docs` - Install terraform-docs
- `make install-tflint` - Install tflint
- `make install-tfsec` - Install tfsec
- `make install-checkov` - Install checkov

For more details, run `make help`.

## Documentation

Each module includes:
- Comprehensive README.md
- Example configurations in `examples/` directory
- Variable and output documentation

## License

This project is licensed under the Apache License 2.0. See [LICENSE](./LICENSE) for details.
