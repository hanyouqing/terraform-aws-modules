output "assume_roles" {
  value = {
    for k, v in aws_iam_role.assume_main_account_role : k => {
      arn           = v.arn
      name          = v.name
      external_id   = var.team_roles[k].external_id
      target_role   = var.team_roles[k].target_role_name
      main_account_id = var.main_account_id
    }
  }
  description = "IAM roles created in identity account for assuming main account roles"
}

output "assume_role_commands" {
  value = {
    for k, v in aws_iam_role.assume_main_account_role : k => {
      assume_command = "aws sts assume-role --role-arn ${v.arn} --role-session-name ${k}-session"
      assume_to_main = "aws sts assume-role --role-arn arn:aws:iam::${var.main_account_id}:role/${var.team_roles[k].target_role_name} --role-session-name ${k}-main-session --external-id ${var.team_roles[k].external_id}"
      profile_setup = <<-EOT
        # Add to ~/.aws/config for assuming identity account role:
        [profile ${k}-identity]
        role_arn = ${v.arn}
        source_profile = identity-sso
        
        # Add to ~/.aws/config for assuming main account role from identity account:
        [profile ${k}-main]
        role_arn = arn:aws:iam::${var.main_account_id}:role/${var.team_roles[k].target_role_name}
        source_profile = ${k}-identity
        external_id = ${var.team_roles[k].external_id}
      EOT
    }
  }
  description = "Commands and profile configuration for assuming roles"
}

