# ============================================================================
# IAM MODULE — GitHub Actions OIDC provider + CI/CD deploy role.
# Lets GitHub Actions assume a role via OIDC (no long-lived AWS keys) to:
#   - push images to ECR
#   - describe the EKS cluster (for kubeconfig, if the pipeline runs kubectl)
# GitOps note: with ArgoCD, CI only pushes images + bumps the tag in Git;
# ArgoCD (in-cluster) does the actual deploy, so kubectl perms are optional.
# ============================================================================

data "aws_partition" "current" {}

# GitHub's OIDC provider (create once per account; skip if it already exists).
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

locals {
  oidc_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_oidc_provider_arn
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:RaveendraKaturu@117171623/zidd2-devops-platform@1333877621:*"]
    }
  }
}

resource "aws_iam_role" "ci" {
  name               = "${var.name}-github-actions-ci"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "ci" {
  statement {
    sid       = "ECRAuth"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid = "ECRPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = var.ecr_repository_arns
  }
  statement {
    sid       = "EKSDescribe"
    actions   = ["eks:DescribeCluster"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ci" {
  name   = "${var.name}-ci-policy"
  role   = aws_iam_role.ci.id
  policy = data.aws_iam_policy_document.ci.json
}



