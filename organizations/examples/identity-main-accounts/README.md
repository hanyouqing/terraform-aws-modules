# Identity and Main Accounts Example

此示例演示如何创建两个 AWS 账户：
- **Identity Account**: 用于 AWS SSO 登录，登录后无任何权限，只能 assume 到 main account 的 team roles
- **Main Account**: 用于创建业务资源，包含 team roles，允许从 identity account assume 过来

## 架构设计

```
┌─────────────────┐
│   AWS SSO       │
│   (Identity)    │
└────────┬────────┘
         │
         │ Assume Role
         ▼
┌─────────────────────────────────┐
│   Identity Account              │
│   - AssumeMainAccount-* Roles   │
│   - No permissions except       │
│     assume role to main account │
└────────────┬─────────────────────┘
             │
             │ Assume Role (with External ID)
             ▼
┌─────────────────────────────────┐
│   Main Account                  │
│   - Team Roles (Developers,     │
│     Operations, Security)       │
│   - Business Resources          │
└─────────────────────────────────┘
```

## 部署步骤

### 1. 创建账户和组织结构

首先在主账户中运行，创建 identity 和 main 账户：

```bash
cd /path/to/organizations/examples/identity-main-accounts

# 复制示例配置
cp terraform.tfvars.example terraform.tfvars

# 编辑 terraform.tfvars，设置账户邮箱等信息
# 然后初始化并应用
terraform init
terraform plan
terraform apply
```

记录输出的账户 ID：
- `identity_account_id`
- `main_account_id`

### 2. 配置 Identity Account

在 identity account 中创建用于 assume main account 的角色：

```bash
cd identity-account

# 复制示例配置
cp terraform.tfvars.example terraform.tfvars

# 编辑 terraform.tfvars，设置账户 ID
# 使用 assume role 方式访问 identity account
terraform init

# 设置 assume role ARN（从步骤 1 的输出获取）
export TF_VAR_aws_assume_role_arn="arn:aws:iam::<identity_account_id>:role/OrganizationAccountAccessRole"

# 或者使用 profile
export TF_VAR_aws_profile="identity-account-profile"

terraform plan
terraform apply
```

### 3. 配置 Main Account

在 main account 中创建 team roles：

```bash
cd main-account

# 复制示例配置
cp terraform.tfvars.example terraform.tfvars

# 编辑 terraform.tfvars，设置账户 ID 和 team roles 配置
# 使用 assume role 方式访问 main account
terraform init

# 设置 assume role ARN（从步骤 1 的输出获取）
export TF_VAR_aws_assume_role_arn="arn:aws:iam::<main_account_id>:role/OrganizationAccountAccessRole"

# 或者使用 profile
export TF_VAR_aws_profile="main-account-profile"

terraform plan
terraform apply
```

## 使用方式

### 方式 1: 使用 AWS Profile（推荐）

配置 `~/.aws/config`：

```ini
# SSO profile for identity account
[profile identity-sso]
sso_start_url = https://your-sso-portal.awsapps.com/start
sso_region = us-east-1
sso_account_id = <identity_account_id>
sso_role_name = AssumeMainAccount-Developers  # 或其他 team role
region = us-east-1

# Profile to assume main account role from identity account
[profile developers-main]
role_arn = arn:aws:iam::<main_account_id>:role/Developers
source_profile = identity-sso
external_id = assume-main-developers
region = us-east-1
```

使用：

```bash
# 登录 SSO
aws sso login --profile identity-sso

# 使用 main account profile
export AWS_PROFILE=developers-main
aws sts get-caller-identity
```

### 方式 2: 使用 Assume Role 命令

```bash
# 1. 登录 SSO 获取 identity account 凭证
aws sso login --profile identity-sso

# 2. Assume identity account role
IDENTITY_CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::<identity_account_id>:role/AssumeMainAccount-Developers \
  --role-session-name dev-session \
  --profile identity-sso)

export AWS_ACCESS_KEY_ID=$(echo $IDENTITY_CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $IDENTITY_CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $IDENTITY_CREDS | jq -r '.Credentials.SessionToken')

# 3. Assume main account role
MAIN_CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::<main_account_id>:role/Developers \
  --role-session-name dev-main-session \
  --external-id assume-main-developers)

export AWS_ACCESS_KEY_ID=$(echo $MAIN_CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $MAIN_CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $MAIN_CREDS | jq -r '.Credentials.SessionToken')

# 4. 验证
aws sts get-caller-identity
```

### 方式 3: 使用 Terraform Provider Assume Role

在 Terraform 代码中使用：

```hcl
provider "aws" {
  region = "us-east-1"
  
  assume_role {
    role_arn     = "arn:aws:iam::<main_account_id>:role/Developers"
    session_name = "terraform-session"
    external_id  = "assume-main-developers"
  }
}
```

## 安全说明

### Identity Account 权限限制

1. **IAM 角色策略**：
   - 默认 deny 所有操作
   - 只允许 `sts:AssumeRole` 到 main account 的对应角色

2. **SCP 策略**：
   - Deny 所有操作，除了：
     - `sts:AssumeRole`
     - `sts:GetCallerIdentity`
     - `OrganizationAccountAccessRole` 的所有操作（用于 Terraform 管理）

### Main Account Team Roles

每个 team role 都有：
- 从 identity account 对应角色 assume 的权限（需要 External ID）
- 实际的业务权限（通过 managed policies 或 inline policies）

## 配置 AWS SSO

### 1. 在 Identity Account 中启用 IAM Identity Center

```bash
# 使用主账户或 identity account 的管理员权限
aws sso-admin create-instance
```

### 2. 创建 Permission Sets

为每个 team 创建 permission set，允许 assume 对应的 identity account 角色：

```bash
# 创建 permission set for developers
aws sso-admin create-permission-set \
  --instance-arn <sso-instance-arn> \
  --name Developers \
  --description "Developers permission set" \
  --session-duration PT1H

# 创建 inline policy，允许 assume AssumeMainAccount-Developers 角色
cat > developers-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::<identity_account_id>:role/AssumeMainAccount-Developers"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws sso-admin put-inline-policy-to-permission-set \
  --instance-arn <sso-instance-arn> \
  --permission-set-arn <permission-set-arn> \
  --inline-policy file://developers-policy.json
```

**工作流程**：
1. 用户通过 SSO 登录到 identity account
2. SSO 创建一个临时角色，该角色有 permission set 定义的权限
3. 用户使用这个临时角色 assume `AssumeMainAccount-*` 角色
4. `AssumeMainAccount-*` 角色可以 assume 到 main account 的对应 team role

### 3. 分配账户和用户

```bash
# 分配 permission set 到 identity account
aws sso-admin create-account-assignment \
  --instance-arn <sso-instance-arn> \
  --target-id <identity_account_id> \
  --target-type AWS_ACCOUNT \
  --permission-set-arn <permission-set-arn> \
  --principal-type USER \
  --principal-id <user-id>
```

## 变量说明

### 主配置 (terraform.tfvars)

- `accounts`: 要创建的账户列表
- `service_control_policies`: SCP 策略列表
- `project`, `environment`, `tags`: 项目配置

### Identity Account 配置

- `identity_account_id`: Identity 账户 ID
- `main_account_id`: Main 账户 ID
- `team_roles`: Team 角色配置
  - `role_name`: Identity account 中的角色名
  - `target_role_name`: Main account 中的目标角色名
  - `external_id`: Assume role 的 External ID
- `sso_permission_set_arns`: SSO permission set ARNs（可选，当前未使用，保留以备将来需要）
- `aws_assume_role_arn`: 用于 Terraform 访问的 assume role ARN
- `aws_profile`: AWS profile 名称

### Main Account 配置

- `identity_account_id`: Identity 账户 ID
- `main_account_id`: Main 账户 ID
- `team_roles`: Team 角色配置
  - `role_name`: Main account 中的角色名
  - `assume_role_name`: Identity account 中的对应角色名
  - `external_id`: Assume role 的 External ID
  - `policy_arns`: 要附加的 managed policy ARNs
  - `inline_policies`: Inline policies
- `aws_assume_role_arn`: 用于 Terraform 访问的 assume role ARN
- `aws_profile`: AWS profile 名称

## 输出说明

### 主配置输出

- `identity_account_id`: Identity 账户 ID
- `main_account_id`: Main 账户 ID
- `accounts`: 所有创建的账户信息

### Identity Account 输出

- `assume_roles`: Identity account 中创建的角色信息
- `assume_role_commands`: Assume role 命令和 profile 配置示例

### Main Account 输出

- `team_roles`: Main account 中创建的 team roles 信息
- `assume_role_commands`: Assume role 命令和 profile 配置示例

## 注意事项

1. **账户创建时间**：账户创建可能需要几分钟，请耐心等待
2. **邮箱唯一性**：每个账户的邮箱地址必须是唯一的
3. **External ID**：用于增强安全性，确保只有知道 External ID 的实体才能 assume role
4. **SCP 限制**：SCP 策略会影响所有附加的账户，请谨慎配置
5. **SSO 配置**：如果使用 SSO，需要在 identity account 中配置 IAM Identity Center

## 故障排查

### 错误：无法 assume role

**可能原因**：
1. External ID 不匹配
2. 角色 ARN 不正确
3. 源账户没有 assume 权限

**解决方案**：
1. 检查 External ID 是否正确
2. 验证角色 ARN 和账户 ID
3. 检查 assume_role_policy 配置

### 错误：权限被拒绝

**可能原因**：
1. SCP 策略限制
2. IAM 角色策略限制

**解决方案**：
1. 检查 SCP 策略是否允许所需操作
2. 验证 IAM 角色策略配置

## 相关资源

- [AWS Organizations 文档](https://docs.aws.amazon.com/organizations/)
- [AWS IAM Identity Center 文档](https://docs.aws.amazon.com/singlesignon/)
- [AWS Assume Role 文档](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html)

