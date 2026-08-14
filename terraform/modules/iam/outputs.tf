output "ci_role_arn" { value = aws_iam_role.ci.arn }
output "oidc_provider_arn" { value = local.oidc_arn }
