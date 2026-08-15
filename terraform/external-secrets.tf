# IRSA role for External Secrets Operator — reads zidd2/* from Secrets Manager
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eso_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:zidd2:external-secrets-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.name}-external-secrets-irsa"
  assume_role_policy = data.aws_iam_policy_document.eso_assume.json
}

data "aws_iam_policy_document" "eso" {
  statement {
    sid       = "ReadZidd2Secrets"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.name}/*"]
  }
}

resource "aws_iam_role_policy" "external_secrets" {
  name   = "${var.name}-external-secrets-policy"
  role   = aws_iam_role.external_secrets.id
  policy = data.aws_iam_policy_document.eso.json
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external_secrets.arn
}
