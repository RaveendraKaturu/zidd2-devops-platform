# ============================================================================
# SECRETS MANAGER MODULE — app secrets stored in AWS Secrets Manager.
# Consumed in-cluster later via the Secrets Store CSI driver / External
# Secrets Operator (wired in the Helm phase). One secret per map entry.
# ============================================================================

resource "aws_secretsmanager_secret" "this" {
  for_each                = var.secrets
  name                    = "${var.name}/${each.key}"
  description             = "zidd2 ${each.key}"
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = var.secrets
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode(each.value)
}
