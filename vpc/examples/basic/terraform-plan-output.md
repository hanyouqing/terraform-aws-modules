# Terraform Pan & Outputs

```bash
terraform apply                                                                                                 ─╯
module.vpc.data.aws_caller_identity.current: Reading...
module.vpc.data.aws_caller_identity.current: Read complete after 1s [id=429613774775]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # module.vpc.data.aws_vpc.main will be read during apply
  # (config refers to values not yet known)
 <= data "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = (known after apply)
      + cidr_block_associations              = (known after apply)
      + default                              = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = (known after apply)
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = (known after apply)
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = (known after apply)
      + state                                = (known after apply)
      + tags                                 = (known after apply)
    }

  # module.vpc.aws_db_subnet_group.main[0] will be created
  + resource "aws_db_subnet_group" "main" {
      + arn                     = (known after apply)
      + description             = "Managed by Terraform"
      + id                      = (known after apply)
      + name                    = "vpc-basic-development-db-subnet-group"
      + name_prefix             = (known after apply)
      + region                  = "us-east-1"
      + subnet_ids              = (known after apply)
      + supported_network_types = (known after apply)
      + tags                    = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-db-subnet-group"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all                = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-db-subnet-group"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id                  = (known after apply)
    }

  # module.vpc.aws_default_security_group.main[0] will be created
  + resource "aws_default_security_group" "main" {
      + arn                    = (known after apply)
      + description            = (known after apply)
      + egress                 = []
      + id                     = (known after apply)
      + ingress                = []
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-default-sg-restricted"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "default-security-group"
        }
      + tags_all               = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-default-sg-restricted"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "default-security-group"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_eip.nat["vpc-basic-development-nat-a"] will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + arn                  = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = "vpc"
      + id                   = (known after apply)
      + instance             = (known after apply)
      + ipam_pool_id         = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + ptr_record           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + region               = "us-east-1"
      + tags                 = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-nat-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-nat-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
    }

  # module.vpc.aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "us-east-1"
      + tags     = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-igw"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-igw"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_nat_gateway.main["vpc-basic-development-nat-a"] will be created
  + resource "aws_nat_gateway" "main" {
      + allocation_id                      = (known after apply)
      + association_id                     = (known after apply)
      + auto_provision_zones               = (known after apply)
      + auto_scaling_ips                   = (known after apply)
      + availability_mode                  = (known after apply)
      + connectivity_type                  = "public"
      + id                                 = (known after apply)
      + network_interface_id               = (known after apply)
      + private_ip                         = (known after apply)
      + public_ip                          = (known after apply)
      + region                             = "us-east-1"
      + regional_nat_gateway_address       = (known after apply)
      + regional_nat_gateway_auto_mode     = (known after apply)
      + route_table_id                     = (known after apply)
      + secondary_allocation_ids           = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ip_addresses     = (known after apply)
      + subnet_id                          = (known after apply)
      + tags                               = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-nat-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-nat-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id                             = (known after apply)
    }

  # module.vpc.aws_route_table.database["vpc-basic-development-database-rt-a"] will be created
  + resource "aws_route_table" "database" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = (known after apply)
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-rt-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-rt-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.database["vpc-basic-development-database-rt-b"] will be created
  + resource "aws_route_table" "database" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = (known after apply)
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-rt-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-rt-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.database["vpc-basic-development-database-rt-c"] will be created
  + resource "aws_route_table" "database" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = (known after apply)
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-rt-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-rt-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.private["vpc-basic-development-private-rt-a"] will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + nat_gateway_id             = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-rt-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-rt-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.private["vpc-basic-development-private-rt-b"] will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + nat_gateway_id             = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-rt-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-rt-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.private["vpc-basic-development-private-rt-c"] will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + nat_gateway_id             = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-rt-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-rt-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-rt"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all         = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-rt"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.database["vpc-basic-development-database-rt-a"] will be created
  + resource "aws_route_table_association" "database" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.database["vpc-basic-development-database-rt-b"] will be created
  + resource "aws_route_table_association" "database" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.database["vpc-basic-development-database-rt-c"] will be created
  + resource "aws_route_table_association" "database" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private["vpc-basic-development-private-rt-a"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private["vpc-basic-development-private-rt-b"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private["vpc-basic-development-private-rt-c"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public["vpc-basic-development-public-a"] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public["vpc-basic-development-public-b"] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public["vpc-basic-development-public-c"] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_security_group.database will be created
  + resource "aws_security_group" "database" {
      + arn                    = (known after apply)
      + description            = "Security group for database subnets"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "vpc-basic-development-database-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + tags_all               = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_security_group.jump will be created
  + resource "aws_security_group" "jump" {
      + arn                    = (known after apply)
      + description            = "Security group for jump server (bastion host)"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "vpc-basic-development-jump-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-jump-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "jump"
        }
      + tags_all               = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-jump-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "jump"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_security_group.private will be created
  + resource "aws_security_group" "private" {
      + arn                    = (known after apply)
      + description            = "Security group for private subnets"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "vpc-basic-development-private-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + tags_all               = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_security_group.public will be created
  + resource "aws_security_group" "public" {
      + arn                    = (known after apply)
      + description            = "Security group for public subnets"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "vpc-basic-development-public-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + tags_all               = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-sg"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_security_group_rule.database_ingress_from_private["1433"] will be created
  + resource "aws_security_group_rule" "database_ingress_from_private" {
      + description              = "vpc-basic-development-database-sg-rule-ingress: Allow port 1433 (1433) from private security group"
      + from_port                = 1433
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 1433
      + type                     = "ingress"
    }

  # module.vpc.aws_security_group_rule.database_ingress_from_private["27017"] will be created
  + resource "aws_security_group_rule" "database_ingress_from_private" {
      + description              = "vpc-basic-development-database-sg-rule-ingress: Allow port 27017 (27017) from private security group"
      + from_port                = 27017
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 27017
      + type                     = "ingress"
    }

  # module.vpc.aws_security_group_rule.database_ingress_from_private["3306"] will be created
  + resource "aws_security_group_rule" "database_ingress_from_private" {
      + description              = "vpc-basic-development-database-sg-rule-ingress: Allow port 3306 (3306) from private security group"
      + from_port                = 3306
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 3306
      + type                     = "ingress"
    }

  # module.vpc.aws_security_group_rule.database_ingress_from_private["5432"] will be created
  + resource "aws_security_group_rule" "database_ingress_from_private" {
      + description              = "vpc-basic-development-database-sg-rule-ingress: Allow port 5432 (5432) from private security group"
      + from_port                = 5432
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 5432
      + type                     = "ingress"
    }

  # module.vpc.aws_security_group_rule.database_ingress_from_private["6379"] will be created
  + resource "aws_security_group_rule" "database_ingress_from_private" {
      + description              = "vpc-basic-development-database-sg-rule-ingress: Allow port 6379 (6379) from private security group"
      + from_port                = 6379
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 6379
      + type                     = "ingress"
    }

  # module.vpc.aws_security_group_rule.private_ingress_ssh_from_jump will be created
  + resource "aws_security_group_rule" "private_ingress_ssh_from_jump" {
      + description              = "vpc-basic-development-private-sg-rule-ssh: Allow SSH (22) from jump security group"
      + from_port                = 22
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # module.vpc.aws_security_group_rule.public_ingress_ssh_from_jump will be created
  + resource "aws_security_group_rule" "public_ingress_ssh_from_jump" {
      + description              = "vpc-basic-development-public-sg-rule-ssh: Allow SSH (22) from jump security group"
      + from_port                = 22
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + region                   = "us-east-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # module.vpc.aws_subnet.database["vpc-basic-development-database-a"] will be created
  + resource "aws_subnet" "database" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.21.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.database["vpc-basic-development-database-b"] will be created
  + resource "aws_subnet" "database" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.22.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.database["vpc-basic-development-database-c"] will be created
  + resource "aws_subnet" "database" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.23.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-database-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "database"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private["vpc-basic-development-private-a"] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.11.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private["vpc-basic-development-private-b"] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.12.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private["vpc-basic-development-private-c"] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.13.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-private-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "private"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public["vpc-basic-development-public-a"] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-a"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public["vpc-basic-development-public-b"] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-b"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public["vpc-basic-development-public-c"] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.3.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + tags_all                                       = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-public-c"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "public"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "us-east-1"
      + tags                                 = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
      + tags_all                             = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
        }
    }

Plan: 42 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + database_subnet_ids           = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + database_subnet_ids_map       = {
      + vpc-basic-development-database-a = (known after apply)
      + vpc-basic-development-database-b = (known after apply)
      + vpc-basic-development-database-c = (known after apply)
    }
  + internet_gateway_arn          = (known after apply)
  + internet_gateway_id           = (known after apply)
  + nat_gateway_ids               = [
      + (known after apply),
    ]
  + nat_gateway_ids_map           = {
      + vpc-basic-development-nat-a = (known after apply)
    }
  + nat_gateway_public_ips        = {
      + vpc-basic-development-nat-a = (known after apply)
    }
  + nat_public_ips                = [
      + (known after apply),
    ]
  + nat_public_ips_map            = {
      + vpc-basic-development-nat-a = (known after apply)
    }
  + private_subnet_ids            = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + private_subnet_ids_map        = {
      + vpc-basic-development-private-a = (known after apply)
      + vpc-basic-development-private-b = (known after apply)
      + vpc-basic-development-private-c = (known after apply)
    }
  + public_subnet_ids             = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + public_subnet_ids_map         = {
      + vpc-basic-development-public-a = (known after apply)
      + vpc-basic-development-public-b = (known after apply)
      + vpc-basic-development-public-c = (known after apply)
    }
  + security_group_ids            = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + security_group_ids_map        = {
      + database = (known after apply)
      + jump     = (known after apply)
      + private  = (known after apply)
      + public   = (known after apply)
    }
  + vpc_cidr_block                = "10.0.0.0/16"
  + vpc_id                        = (known after apply)
  + vpc_name                      = "vpc-basic-development"
  + zzz_allowlist_update_reminder = (known after apply)
  + zzz_reminders                 = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vpc.aws_vpc.main: Creating...
module.vpc.aws_vpc.main: Still creating... [00m10s elapsed]
...
Releasing state lock. This may take a few moments...

Apply complete! Resources: 42 added, 0 changed, 0 destroyed.

Outputs:

database_subnet_ids = [
  "subnet-05331ab5a6f9d9376",
  "subnet-0d41cc284df81f7f7",
  "subnet-0036cee0e8128c35d",
]
database_subnet_ids_map = {
  "vpc-basic-development-database-a" = "subnet-05331ab5a6f9d9376"
  "vpc-basic-development-database-b" = "subnet-0d41cc284df81f7f7"
  "vpc-basic-development-database-c" = "subnet-0036cee0e8128c35d"
}
internet_gateway_arn = "arn:aws:ec2:us-east-1:429613774775:internet-gateway/igw-053644e90719fc0b1"
internet_gateway_id = "igw-053644e90719fc0b1"
nat_gateway_ids = [
  "nat-07f884e1e5748fa97",
]
nat_gateway_ids_map = {
  "vpc-basic-development-nat-a" = "nat-07f884e1e5748fa97"
}
nat_gateway_public_ips = {
  "vpc-basic-development-nat-a" = "54.83.41.62"
}
nat_public_ips = [
  "54.83.41.62",
]
nat_public_ips_map = {
  "vpc-basic-development-nat-a" = "54.83.41.62"
}
private_subnet_ids = [
  "subnet-0ebf8566b6c8e4980",
  "subnet-0edf932d15bdc6a95",
  "subnet-053b35b07107fa068",
]
private_subnet_ids_map = {
  "vpc-basic-development-private-a" = "subnet-0ebf8566b6c8e4980"
  "vpc-basic-development-private-b" = "subnet-0edf932d15bdc6a95"
  "vpc-basic-development-private-c" = "subnet-053b35b07107fa068"
}
public_subnet_ids = [
  "subnet-0ac9773d2ac525473",
  "subnet-039a0ae25316b6861",
  "subnet-06b0c11a417c2a0f7",
]
public_subnet_ids_map = {
  "vpc-basic-development-public-a" = "subnet-0ac9773d2ac525473"
  "vpc-basic-development-public-b" = "subnet-039a0ae25316b6861"
  "vpc-basic-development-public-c" = "subnet-06b0c11a417c2a0f7"
}
security_group_ids = [
  "sg-0e73dd54673dcc3bc",
  "sg-0b5de194b7c0b05b9",
  "sg-07509b6e75a8a01fb",
  "sg-05e0d6cdb96046af8",
]
security_group_ids_map = {
  "database" = "sg-05e0d6cdb96046af8"
  "jump" = "sg-0e73dd54673dcc3bc"
  "private" = "sg-07509b6e75a8a01fb"
  "public" = "sg-0b5de194b7c0b05b9"
}
vpc_cidr_block = "10.0.0.0/16"
vpc_id = "vpc-0e1c3ee3c6be19dce"
vpc_name = "vpc-basic-development"
zzz_allowlist_update_reminder = <<EOT
⚠️  REMINDER: VPC Allowlist and Post-Deployment Tasks
=======================================================

Allowlist Information:
- IPv4 Prefix List: Not configured
- IPv6 Prefix List: Not configured

Pending Tasks:
1. EKS Public Access:
   - Verify EKS cluster endpoint_public_access_cidrs uses VPC allowlist prefix list
   - Ensure EKS public access is properly restricted to allowlist IPs only

2. AWS ALB (Application Load Balancer):
   - ⚠️  IMPORTANT: ALB does NOT support direct prefix list binding
   - ALB can only use prefix list through security group rules
   - Check if any ALB security groups use 0.0.0.0/0 (allows all IPs)
   - Recommendation: Update ALB security group rules to use allowlist prefix list
   - Action: Add security group rules using prefix_list_ids instead of cidr_blocks

3. Other:
   - Review and update any other resources that should use allowlist
   - Consider adding allowlist rules to VPC public security group if needed

Applied at: 2026-01-14T02:18:38Z by 429613774775

EOT
zzz_reminders = <<EOT
📝  REMINDER: Using VPC Remote State in Other Modules
=======================================================

This VPC module has been successfully deployed. Use the following examples to reference
VPC outputs when creating EC2, RDS, Redis, and other resources.

1. Remote State Configuration (data.tf or main.tf)
---------------------------------------------------
# Add this to your EC2, RDS, or Redis module's data.tf or main.tf

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = "terraform-aws-modules-example-state"  # Replace with your actual bucket name
    key                  = "hanyouqing/terraform-aws-modules:vpc/examples/basic/terraform.tfstate"  # Replace with your actual state key
    region               = "us-east-1"  # Replace with your actual region
    workspace_key_prefix = "env:"
  }
}

# Variables needed (add to variables.tf):
# variable "vpc_remote_state_bucket" {
#   description = "S3 bucket name for VPC remote state"
#   type        = string
# }
#
# variable "vpc_remote_state_key" {
#   description = "Remote state key for VPC module"
#   type        = string
#   default     = "hanyouqing/terraform-aws-modules:vpc/examples/basic/terraform.tfstate"
# }

2. EC2 Instance Example
------------------------
# Example: Create EC2 instance in private subnet with security groups

resource "aws_instance" "app" {
  ami           = "ami-xxxxx"
  instance_type = "t3.micro"

  # Use private subnet (by name)
  # Note: Replace "your-project-development" with your actual VPC name
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids_map["your-project-development-private-a"]

  # Use security groups (map format)
  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.security_group_ids_map["private"],
    data.terraform_remote_state.vpc.outputs.security_group_ids_map["jump"],  # For SSH access
  ]

  # Alternative: Use list format
  # vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.security_group_ids

  tags = {
    Name = "your-project-development-app"
  }
}

# Alternative: Use subnet by index (list format)
# subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]

3. RDS Database Example
------------------------
# Example: Create RDS instance in database subnets

resource "aws_db_instance" "main" {
  identifier     = "your-project-development-db"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"

  # Use database subnet group
  db_subnet_group_name = data.terraform_remote_state.vpc.outputs.database_subnet_group_id

  # Use database security group (map format)
  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.security_group_ids_map["database"]
  ]

  # Alternative: Use list format
  # vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.security_group_ids

  # Allow access from private security group
  # (configured via security group rules in VPC module)

  allocated_storage     = 20
  storage_encrypted     = true
  backup_retention_period = 7

  tags = {
    Name = "your-project-development-db"
  }
}

# Example: RDS with specific subnet (by name)
# subnet_ids = [
#   data.terraform_remote_state.vpc.outputs.database_subnet_ids_map["your-project-development-database-a"],
#   data.terraform_remote_state.vpc.outputs.database_subnet_ids_map["your-project-development-database-b"]
# ]

4. ElastiCache (Redis) Example
-------------------------------
# Example: Create Redis cluster in private subnets

resource "aws_elasticache_subnet_group" "main" {
  name       = "your-project-development-redis-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "your-project-development-redis"
  description                = "Redis cluster for your-project-development"

  node_type                  = "cache.t3.micro"
  port                       = 6379
  parameter_group_name       = "default.redis7"

  # Use subnet group
  subnet_group_name = aws_elasticache_subnet_group.main.name

  # Use security groups (map format)
  security_group_ids = [
    data.terraform_remote_state.vpc.outputs.security_group_ids_map["private"]
  ]

  # Alternative: Use list format
  # security_group_ids = data.terraform_remote_state.vpc.outputs.security_group_ids

  num_cache_clusters = 2

  tags = {
    Name = "your-project-development-redis"
  }
}

5. Application Load Balancer (ALB) Example
-------------------------------------------
# Example: Create ALB in public subnets

resource "aws_lb" "main" {
  name               = "your-project-development-alb"
  internal           = false
  load_balancer_type = "application"

  # Use public subnets
  subnets = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Use security groups (map format)
  security_groups = [
    data.terraform_remote_state.vpc.outputs.security_group_ids_map["public"]
  ]

  # Alternative: Use list format
  # security_groups = data.terraform_remote_state.vpc.outputs.security_group_ids

  enable_deletion_protection = false

  tags = {
    Name = "your-project-development-alb"
  }
}

# Example: ALB with specific subnets (by name)
# subnets = [
#   data.terraform_remote_state.vpc.outputs.public_subnet_ids_map["your-project-development-public-a"],
#   data.terraform_remote_state.vpc.outputs.public_subnet_ids_map["your-project-development-public-b"]
# ]

6. EKS Cluster Example
------------------------
# Example: Create EKS cluster using VPC outputs

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "your-project-development-eks"
  cluster_version = "1.28"

  # Use VPC outputs
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Use security groups
  cluster_security_group_additional_rules = {
    ingress_from_allowlist = {
      type                     = "ingress"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = data.terraform_remote_state.vpc.outputs.security_group_ids_map["jump"]
    }
  }

  # Use allowlist prefix list for public access
  cluster_endpoint_public_access_cidrs = [
    data.terraform_remote_state.vpc.outputs.allowlist_prefix_list_id_ipv4
  ]
}

7. VPC Endpoints Example
-------------------------
# Example: Create VPC endpoint in private subnets

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  service_name = "com.amazonaws.us-east-1.s3"

  # Use route tables
  route_table_ids = concat(
    data.terraform_remote_state.vpc.outputs.private_route_table_ids,
    data.terraform_remote_state.vpc.outputs.database_route_table_ids
  )

  tags = {
    Name = "your-project-development-s3-endpoint"
  }
}

8. Common VPC Outputs Reference
---------------------------------
# VPC Information
vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
vpc_cidr_block            = data.terraform_remote_state.vpc.outputs.vpc_cidr_block

# Subnets (List Format - for backward compatibility)
public_subnet_ids         = data.terraform_remote_state.vpc.outputs.public_subnet_ids
private_subnet_ids        = data.terraform_remote_state.vpc.outputs.private_subnet_ids
database_subnet_ids       = data.terraform_remote_state.vpc.outputs.database_subnet_ids

# Subnets (Map Format - recommended, by name)
public_subnet_ids_map     = data.terraform_remote_state.vpc.outputs.public_subnet_ids_map
private_subnet_ids_map    = data.terraform_remote_state.vpc.outputs.private_subnet_ids_map
database_subnet_ids_map   = data.terraform_remote_state.vpc.outputs.database_subnet_ids_map

# Security Groups (List Format - for backward compatibility)
security_group_ids        = data.terraform_remote_state.vpc.outputs.security_group_ids

# Security Groups (Map Format - recommended)
security_group_ids_map     = data.terraform_remote_state.vpc.outputs.security_group_ids_map
# Access: security_group_ids_map["jump"], security_group_ids_map["public"], etc.

# NAT Gateways
nat_gateway_ids           = data.terraform_remote_state.vpc.outputs.nat_gateway_ids
nat_gateway_ids_map       = data.terraform_remote_state.vpc.outputs.nat_gateway_ids_map

# Route Tables
private_route_table_ids   = data.terraform_remote_state.vpc.outputs.private_route_table_ids
database_route_table_ids  = data.terraform_remote_state.vpc.outputs.database_route_table_ids

# Allowlist Prefix Lists
allowlist_prefix_list_id_ipv4 = data.terraform_remote_state.vpc.outputs.allowlist_prefix_list_id_ipv4
allowlist_prefix_list_ids_map = data.terraform_remote_state.vpc.outputs.allowlist_prefix_list_ids_map

# Route53 Zones (if domain is configured)
hosted_zone_id            = data.terraform_remote_state.vpc.outputs.hosted_zone_id
route53_zone_ids_map      = data.terraform_remote_state.vpc.outputs.route53_zone_ids_map

# Database Subnet Group (for RDS)
database_subnet_group_id  = data.terraform_remote_state.vpc.outputs.database_subnet_group_id

9. Best Practices
------------------
- Use map format outputs (e.g., subnet_ids_map) for better readability and maintainability
- Use security_group_ids_map for consistent security group references (recommended)
- Use security_group_ids list format for backward compatibility
- Always reference subnets by name when using map format for clarity
- Use database_subnet_group_id for RDS instead of manually selecting subnets
- Use allowlist_prefix_list_ids_map for consistent allowlist management

10. Troubleshooting
--------------------
- If remote state is not found, verify:
  * S3 bucket name matches vpc_remote_state_bucket
  * State key matches vpc_remote_state_key
  * Workspace matches (if using workspaces)
  * Region matches
- If outputs are null, ensure VPC module has been applied successfully
- Use terraform state list to verify outputs are available

Last Applied: 2026-01-14T02:18:38Z by arn:aws:iam::1233345345345:root

EOT
```

Add domain & certificate

```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.aws_acm_certificate.environment[0] will be created
  + resource "aws_acm_certificate" "environment" {
      + arn                       = (known after apply)
      + domain_name               = "development.aws.hanyouqing.com"
      + domain_validation_options = [
          + {
              + domain_name           = "*.development.aws.hanyouqing.com"
              + resource_record_name  = (known after apply)
              + resource_record_type  = (known after apply)
              + resource_record_value = (known after apply)
            },
          + {
              + domain_name           = "development.aws.hanyouqing.com"
              + resource_record_name  = (known after apply)
              + resource_record_type  = (known after apply)
              + resource_record_value = (known after apply)
            },
        ]
      + id                        = (known after apply)
      + key_algorithm             = (known after apply)
      + not_after                 = (known after apply)
      + not_before                = (known after apply)
      + pending_renewal           = (known after apply)
      + region                    = "us-east-1"
      + renewal_eligibility       = (known after apply)
      + renewal_summary           = (known after apply)
      + status                    = (known after apply)
      + subject_alternative_names = [
          + "*.development.aws.hanyouqing.com",
          + "development.aws.hanyouqing.com",
        ]
      + tags                      = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-certificate"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "acm-certificate"
        }
      + tags_all                  = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-certificate"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "acm-certificate"
        }
      + type                      = (known after apply)
      + validation_emails         = (known after apply)
      + validation_method         = "DNS"

      + options (known after apply)
    }

  # module.vpc.aws_acm_certificate_validation.environment[0] will be created
  + resource "aws_acm_certificate_validation" "environment" {
      + certificate_arn         = (known after apply)
      + id                      = (known after apply)
      + region                  = "us-east-1"
      + validation_record_fqdns = (known after apply)

      + timeouts {
          + create = "5m"
        }
    }

  # module.vpc.aws_route53_record.certificate_validation["*.development.aws.hanyouqing.com"] will be created
  + resource "aws_route53_record" "certificate_validation" {
      + allow_overwrite = true
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = (known after apply)
      + records         = (known after apply)
      + ttl             = 60
      + type            = (known after apply)
      + zone_id         = (known after apply)
    }

  # module.vpc.aws_route53_record.certificate_validation["development.aws.hanyouqing.com"] will be created
  + resource "aws_route53_record" "certificate_validation" {
      + allow_overwrite = true
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = (known after apply)
      + records         = (known after apply)
      + ttl             = 60
      + type            = (known after apply)
      + zone_id         = (known after apply)
    }

  # module.vpc.aws_route53_zone.main[0] will be created
  + resource "aws_route53_zone" "main" {
      + arn                         = (known after apply)
      + comment                     = "Hosted zone for development environment"
      + enable_accelerated_recovery = (known after apply)
      + force_destroy               = false
      + id                          = (known after apply)
      + name                        = "development.aws.hanyouqing.com"
      + name_servers                = (known after apply)
      + primary_name_server         = (known after apply)
      + tags                        = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-hosted-zone"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "hosted-zone"
        }
      + tags_all                    = {
          + "Code"        = "hanyouqing/terraform-aws-modules:vpc/examples/basic"
          + "CostCenter"  = "Infrastructure"
          + "Environment" = "development"
          + "ManagedBy"   = "terraform"
          + "Name"        = "vpc-basic-development-hosted-zone"
          + "Owner"       = "DevOps"
          + "Project"     = "vpc-basic"
          + "Type"        = "hosted-zone"
        }
      + zone_id                     = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```