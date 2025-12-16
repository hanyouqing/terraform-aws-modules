output "team_roles" {
  value = {
    for k, v in aws_iam_role.team_roles : k => {
      arn        = v.arn
      name       = v.name
      external_id = var.team_roles[k].external_id
    }
  }
  description = "Team roles created in main account"
}

output "assume_role_commands" {
  value = {
    for k, v in aws_iam_role.team_roles : k => {
      command = "aws sts assume-role --role-arn ${v.arn} --role-session-name ${k}-session --external-id ${var.team_roles[k].external_id}"
      profile_setup = <<-EOT
        # Add to ~/.aws/config:
        [profile ${k}-main]
        role_arn = ${v.arn}
        source_profile = identity-sso
        external_id = ${var.team_roles[k].external_id}
      EOT
    }
  }
  description = "Commands and profile configuration for assuming team roles"
}

