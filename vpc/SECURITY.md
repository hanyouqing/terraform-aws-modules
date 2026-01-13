# VPC Module Security Guide

This document outlines the security features and best practices for the VPC module.

## Security Features

### 1. Network ACLs (Defense in Depth)

Network ACLs provide an additional layer of security at the subnet level. They are stateless and operate before security groups.

**Enable**: `enable_network_acls = true`

**Features**:
- Default NACL: Restrictive (deny all ingress, allow all egress)
- Public NACL: Allows HTTP (80), HTTPS (443), and ephemeral ports
- Private NACL: Allows traffic from VPC CIDR and ephemeral ports
- Database NACL: Most restrictive - only allows traffic from VPC CIDR

**Best Practice**: Enable Network ACLs for production environments to add defense in depth.

### 2. Default Security Group Restriction

The default security group should be restricted to deny all traffic. This prevents accidental use of the default security group.

**Enable**: `restrict_default_security_group = true` (default: `true`)

**Features**:
- Removes all default ingress rules
- Removes all default egress rules
- Forces use of custom security groups

**Best Practice**: Always enable this in production. Users should create and use custom security groups.

### 3. Security Group Rules

#### Explicit Egress Rules

By default, security groups allow all egress traffic. For enhanced security, you can enable explicit egress rules.

**Enable**: `enable_explicit_egress_rules = true`

**Features**:
- Explicit egress rules for all security groups
- Configurable egress CIDR blocks
- Better visibility and control

#### Public Security Group Allowlist

Restrict public security group access to allowlist IPs only.

**Enable**: `public_security_group_allowlist_enabled = true`

**Features**:
- Uses Managed Prefix List for allowlist
- Only allowlist IPs can access public resources
- Prevents unauthorized access

#### Database Security Group Rules

Configure database security group to only allow access from application tier.

**Configuration**:
```hcl
database_security_group_allowed_ports = [3306, 5432]  # MySQL, PostgreSQL
database_security_group_allowed_cidr_blocks = ["10.0.11.0/24"]  # Private subnets
```

**Features**:
- Allows access from private security group (application tier)
- Allows access from specified CIDR blocks
- Configurable database ports

### 4. VPC Flow Logs Security

#### IAM Role Policy

The IAM role policy for VPC Flow Logs is restricted to specific log groups (not `*`).

**Security Improvement**:
- Policy scoped to specific CloudWatch Log Group ARN
- Follows principle of least privilege
- Prevents access to other log groups

#### Encryption

Enable encryption for CloudWatch Logs and S3 Flow Logs.

**Configuration**:
```hcl
cloudwatch_logs_encryption_enabled = true
cloudwatch_logs_kms_key_id = "arn:aws:kms:..."
flow_log_s3_encryption_enabled = true
```

**Features**:
- KMS encryption for CloudWatch Logs
- S3 encryption for Flow Logs (default: enabled)
- Protects sensitive network flow data

### 5. VPC Endpoint Policies

Restrict VPC endpoint access using endpoint policies.

**Enable**: `vpc_endpoint_policy_enabled = true`

**Features**:
- Restrictive endpoint policies
- Source VPC condition (only from this VPC)
- Specific action permissions
- Prevents unauthorized access to AWS services

### 6. Security Group Rule Count Monitoring

Track security group rule counts to ensure compliance with AWS limits (60 rules per direction).

**Output**: `security_group_rule_counts`

**Features**:
- Real-time rule count tracking
- Per-security-group breakdown
- Ingress and egress counts
- Total rule counts

## Security Best Practices

### 1. Enable All Security Features for Production

```hcl
module "vpc" {
  source = "./vpc"

  # Security features
  restrict_default_security_group = true
  enable_network_acls = true
  enable_explicit_egress_rules = true
  public_security_group_allowlist_enabled = true
  vpc_endpoint_policy_enabled = true
  cloudwatch_logs_encryption_enabled = true
  
  # Flow Logs
  enable_flow_log = true
  flow_log_destination_type = "cloud-watch-logs"
  
  # Allowlist
  allowlist_ipv4_blocks = [
    {
      cidr = "203.0.113.0/24"
      description = "Office network"
    }
  ]
}
```

### 2. Database Security

```hcl
# Only allow access from application tier
database_security_group_allowed_ports = [3306]  # MySQL
database_security_group_allowed_cidr_blocks = []  # Use security group references only
```

### 3. Public Security Group

```hcl
# Restrict public access to allowlist only
public_security_group_allowlist_enabled = true
public_security_group_allowed_tcp_ports = [80, 443]  # HTTP, HTTPS only
```

### 4. VPC Endpoints

```hcl
# Enable VPC endpoints for security and cost savings
enable_vpc_endpoints = true
vpc_endpoint_policy_enabled = true  # Restrictive policies
```

### 5. Flow Logs

```hcl
# Enable Flow Logs for security auditing
enable_flow_log = true
flow_log_destination_type = "cloud-watch-logs"
cloudwatch_logs_encryption_enabled = true
cloudwatch_logs_kms_key_id = "arn:aws:kms:..."
```

## Security Checklist

### Pre-Production

- [ ] Enable Network ACLs (`enable_network_acls = true`)
- [ ] Restrict default security group (`restrict_default_security_group = true`)
- [ ] Enable public security group allowlist (`public_security_group_allowlist_enabled = true`)
- [ ] Configure database security group rules (only from app tier)
- [ ] Enable VPC endpoint policies (`vpc_endpoint_policy_enabled = true`)
- [ ] Enable Flow Logs encryption
- [ ] Configure allowlist IPs (never use `0.0.0.0/0`)
- [ ] Review security group rule counts (ensure < 60 per direction)
- [ ] Enable explicit egress rules (`enable_explicit_egress_rules = true`)

### Post-Deployment

- [ ] Verify default security group is restricted
- [ ] Verify Network ACLs are applied
- [ ] Verify Flow Logs are working
- [ ] Test database access (should only work from app tier)
- [ ] Test public access (should only work from allowlist)
- [ ] Review CloudWatch alarms
- [ ] Monitor security group rule counts

## Security Group Rule Limits

AWS limits security groups to **60 rules per direction** (ingress/egress).

The module provides `security_group_rule_counts` output to monitor rule counts:

```hcl
output "security_group_rule_counts" {
  value = module.vpc.security_group_rule_counts
}
```

**Recommendation**: Keep rule counts below 50 to allow for future expansion.

## Network ACLs vs Security Groups

| Feature | Network ACLs | Security Groups |
|---------|--------------|-----------------|
| Level | Subnet | Instance |
| Stateful | No | Yes |
| Rules | Allow/Deny | Allow only |
| Evaluation | In order | All rules |
| Use Case | Defense in depth | Primary security |

**Best Practice**: Use both Network ACLs and Security Groups for defense in depth.

## Encryption

### CloudWatch Logs Encryption

```hcl
cloudwatch_logs_encryption_enabled = true
cloudwatch_logs_kms_key_id = "arn:aws:kms:region:account:key/key-id"
```

### S3 Flow Logs Encryption

S3 encryption is enabled by default (`flow_log_s3_encryption_enabled = true`).

## Access Control

### VPC Endpoint Policies

When `vpc_endpoint_policy_enabled = true`, endpoints have restrictive policies:

- Source VPC condition (only from this VPC)
- Specific action permissions
- No wildcard resources

### Security Group Rules

- Use security group references instead of CIDR blocks when possible
- Use Managed Prefix List for allowlist
- Minimize use of `0.0.0.0/0`

## Monitoring and Auditing

### VPC Flow Logs

Enable Flow Logs for:
- Network traffic monitoring
- Security incident investigation
- Compliance auditing
- Troubleshooting

### CloudWatch Alarms

Enable CloudWatch alarms for:
- NAT Gateway bandwidth monitoring
- Flow Logs error detection
- Cost anomaly detection

## Common Security Issues

### 1. Default Security Group Not Restricted

**Issue**: Default security group allows all traffic by default.

**Solution**: Set `restrict_default_security_group = true`

### 2. Public Security Group Too Permissive

**Issue**: Public security group allows access from `0.0.0.0/0`.

**Solution**: Enable `public_security_group_allowlist_enabled = true` and configure allowlist.

### 3. Database Security Group Too Permissive

**Issue**: Database security group allows access from anywhere.

**Solution**: Configure `database_security_group_allowed_cidr_blocks` and use security group references.

### 4. Flow Logs Not Encrypted

**Issue**: Flow Logs contain sensitive network data but are not encrypted.

**Solution**: Enable `cloudwatch_logs_encryption_enabled = true` and provide KMS key.

### 5. VPC Endpoints Without Policies

**Issue**: VPC endpoints allow access from any VPC.

**Solution**: Enable `vpc_endpoint_policy_enabled = true` to restrict access.

## References

- [AWS VPC Security Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html)
- [AWS Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
- [AWS VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [AWS VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
