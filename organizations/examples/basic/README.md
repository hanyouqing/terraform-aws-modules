# AWS Organizations 基本示例

此示例演示如何使用 organizations 模块创建 AWS 子账户、组织单元和服务控制策略。

## 前置要求

1. **AWS Organizations 已启用**
   - 必须在主账户（Master Account）中运行此示例
   - 需要具有 `organizations:*` 权限

2. **AWS 凭证配置**

   使用环境变量或 AWS 配置文件：

   ```bash
   export AWS_ACCESS_KEY_ID=your-access-key
   export AWS_SECRET_ACCESS_KEY=your-secret-key
   export AWS_DEFAULT_REGION=us-east-1
   ```

   或使用 AWS SSO：

   ```bash
   aws sso login --profile your-profile
   export AWS_PROFILE=your-profile
   ```

## 使用方法

1. **复制示例变量文件**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **编辑 terraform.tfvars**

   修改账户邮箱地址和其他配置：

   ```hcl
   accounts = [
     {
       name                       = "development"
       email                      = "your-email+development@example.com"  # 修改为您的邮箱
       iam_user_access_to_billing = "ALLOW"
       role_name                 = "OrganizationAccountAccessRole"
       close_on_deletion         = false
     }
   ]
   ```

3. **初始化 Terraform**

   ```bash
   terraform init
   ```

4. **预览变更**

   ```bash
   terraform plan
   ```

5. **应用变更**

   ```bash
   terraform apply
   ```

## 注意事项

1. **账户邮箱唯一性**
   - 每个账户的邮箱地址必须是唯一的
   - 邮箱地址不能与现有 AWS 账户关联
   - 建议使用专用邮箱地址或邮箱别名（如 `your-email+account-name@example.com`）

2. **账户创建时间**
   - 账户创建可能需要几分钟时间
   - Terraform 会等待账户创建完成

3. **角色访问**
   - 新账户会自动创建 `OrganizationAccountAccessRole` 角色
   - 可以通过此角色从主账户访问新账户

4. **SCP 策略**
   - SCP 策略会影响所有附加的账户和 OU
   - 建议先在测试账户中验证策略
   - `targets = []` 表示附加到根 OU

## 输出

运行 `terraform apply` 后，可以查看以下输出：

- `organization_id`: AWS Organizations 组织 ID
- `organization_arn`: AWS Organizations 组织 ARN
- `master_account_id`: 主账户 ID
- `accounts`: 创建的账户信息
- `organizational_units`: 创建的组织单元信息
- `service_control_policies`: 创建的服务控制策略信息

查看输出：

```bash
terraform output
```

## 清理资源

删除所有创建的账户和资源：

```bash
terraform destroy
```

**注意**: 删除账户可能需要一些时间，并且账户必须为空（没有资源）才能删除。

