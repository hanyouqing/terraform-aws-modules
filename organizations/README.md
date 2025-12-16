# AWS Organizations Terraform 模块

此模块使用 Terraform 管理 AWS Organizations，包括创建子账户、组织单元（OU）和服务控制策略（SCP）。

## 功能特性

- ✅ 创建和管理 AWS 子账户
- ✅ 创建和管理组织单元（Organizational Units）
- ✅ 创建和管理服务控制策略（Service Control Policies）
- ✅ 支持账户标签管理
- ✅ 灵活的 AWS Provider 配置（支持多种认证方式）
- ✅ 支持账户删除保护

## ⚠️ 重要提示

### 前置要求

1. **AWS Organizations 已启用**
   - 必须在主账户（Master Account）中运行此模块
   - 需要具有 `organizations:*` 权限

2. **账户邮箱唯一性**
   - 每个账户的邮箱地址必须是唯一的
   - 邮箱地址不能与现有 AWS 账户关联

3. **权限要求**
   - 需要 `organizations:CreateAccount` 权限
   - 需要 `organizations:CreateOrganizationalUnit` 权限
   - 需要 `organizations:CreatePolicy` 权限
   - 需要 `organizations:AttachPolicy` 权限

### AWS Provider 配置

#### 方式 1: 使用 AWS SSO（推荐）

```bash
aws sso login --profile your-profile
export AWS_PROFILE=your-profile
```

#### 方式 2: 使用 IAM 用户 Access Key

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

#### 方式 3: 使用 Assume Role

在 `terraform.tfvars` 中配置：

```hcl
aws_assume_role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
```

## 使用方法

### 基本示例

```hcl
module "organizations" {
  source = "./organizations"

  region = "us-east-1"

  accounts = [
    {
      name                       = "development"
      email                      = "aws-dev+development@example.com"
      iam_user_access_to_billing = "ALLOW"
      role_name                 = "OrganizationAccountAccessRole"
      close_on_deletion         = false
    }
  ]

  project     = "my-project"
  environment = "production"
}
```

### 创建多个账户

```hcl
accounts = [
  {
    name                       = "development"
    email                      = "aws-dev+development@example.com"
    iam_user_access_to_billing = "ALLOW"
    role_name                 = "OrganizationAccountAccessRole"
    close_on_deletion         = false
  },
  {
    name                       = "staging"
    email                      = "aws-dev+staging@example.com"
    iam_user_access_to_billing = "ALLOW"
    role_name                 = "OrganizationAccountAccessRole"
    close_on_deletion         = false
  },
  {
    name                       = "production"
    email                      = "aws-dev+production@example.com"
    iam_user_access_to_billing = "DENY"
    role_name                 = "OrganizationAccountAccessRole"
    close_on_deletion         = true
  }
]
```

### 创建组织单元（OU）

```hcl
organizational_units = [
  {
    name      = "Workloads"
    parent_id = null  # null 表示根 OU
    tags = {
      Purpose = "Application workloads"
    }
  },
  {
    name      = "Security"
    parent_id = null
    tags = {
      Purpose = "Security and compliance"
    }
  }
]
```

### 创建服务控制策略（SCP）

```hcl
service_control_policies = [
  {
    name        = "DenyRootUser"
    description = "Prevent root user actions"
    type        = "SERVICE_CONTROL_POLICY"
    content = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Deny"
          Action   = "*"
          Resource = "*"
          Condition = {
            StringLike = {
              "aws:PrincipalArn" = "arn:aws:iam::*:root"
            }
          }
        }
      ]
    })
    targets = []  # 空数组表示附加到根 OU
  }
]
```

## 变量说明

### accounts

| 变量名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| name | string | 是 | - | 账户名称 |
| email | string | 是 | - | 账户邮箱（必须唯一） |
| iam_user_access_to_billing | string | 否 | "ALLOW" | IAM 用户访问账单的权限（ALLOW/DENY） |
| role_name | string | 否 | "OrganizationAccountAccessRole" | 组织账户访问角色名称 |
| close_on_deletion | bool | 否 | false | 删除时是否关闭账户 |
| tags | map(string) | 否 | {} | 账户标签 |

### organizational_units

| 变量名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| name | string | 是 | - | OU 名称 |
| parent_id | string | 否 | null | 父 OU ID（null 表示根 OU） |
| tags | map(string) | 否 | {} | OU 标签 |

### service_control_policies

| 变量名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| name | string | 是 | - | SCP 名称 |
| description | string | 否 | "" | SCP 描述 |
| content | string | 是 | - | SCP 策略内容（JSON） |
| type | string | 否 | "SERVICE_CONTROL_POLICY" | 策略类型 |
| targets | list(string) | 否 | [] | 目标 OU 或账户 ID 列表 |

## 输出说明

- `organization_id`: AWS Organizations 组织 ID
- `organization_arn`: AWS Organizations 组织 ARN
- `master_account_id`: 主账户 ID
- `master_account_email`: 主账户邮箱
- `accounts`: 创建的账户信息（ID、ARN、名称、邮箱、状态等）
- `organizational_units`: 创建的组织单元信息
- `service_control_policies`: 创建的服务控制策略信息

## 注意事项

1. **账户创建时间**
   - 账户创建可能需要几分钟时间
   - Terraform 会等待账户创建完成

2. **账户邮箱**
   - 邮箱地址必须是有效的邮箱格式
   - 不能与现有 AWS 账户关联
   - 建议使用专用邮箱地址

3. **角色名称**
   - 默认角色名称为 `OrganizationAccountAccessRole`
   - 此角色会在新账户中自动创建
   - 可以通过此角色访问新账户

4. **SCP 策略**
   - SCP 策略会影响所有附加的账户和 OU
   - 建议先在测试账户中验证策略
   - SCP 策略不能授予权限，只能拒绝权限

5. **成本**
   - 创建账户本身是免费的
   - 但账户中的资源会产生费用
   - 建议为每个账户设置预算告警

## 示例

完整示例请参考：[示例目录](./examples/)

## 相关资源

- [AWS Organizations 文档](https://docs.aws.amazon.com/organizations/)
- [Terraform AWS Provider - Organizations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account)

