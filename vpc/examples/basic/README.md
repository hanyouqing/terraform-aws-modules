# Basic VPC Example

This example demonstrates a minimal VPC configuration suitable for testing environments.

## Features

- Single VPC with public, private, and database subnets
- Single NAT Gateway (cost-optimized for non-production)
- VPC Flow Logs enabled
- Multi-AZ deployment (3 availability zones)
- Basic security groups

## Usage

1. Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values

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

## Configuration

Update the following variables in `terraform.tfvars`:

- `region`: AWS region (default: us-east-1)
- `project`: Project name
- `environment`: Environment name (testing, staging, production)
- `vpc_cidr`: CIDR block for VPC (default: 10.0.0.0/16)
- `availability_zones`: List of availability zones
- `public_subnets`: CIDR blocks for public subnets
- `private_subnets`: CIDR blocks for private subnets
- `database_subnets`: CIDR blocks for database subnets

## Cost Considerations

This basic example uses cost-optimized settings:

- **Single NAT Gateway**: ~$32/month (vs ~$96/month for multi-AZ)
- **VPC Flow Logs**: ~$5-10/month (depending on traffic)
- **Total Estimated Cost**: ~$40-50/month

For production environments, consider using the `complete` example with multiple NAT Gateways for high availability.

## Outputs

After deployment, you can use the outputs to reference the VPC and subnets in other modules:

```hcl
module "eks" {
  source = "path/to/eks-module"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

