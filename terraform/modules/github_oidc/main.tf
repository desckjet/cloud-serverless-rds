locals {
  module_tags = merge(var.tags, { Module = "github-oidc" })

  # Default subject claims for GitHub Actions (main + feature branches)
  default_subjects = [
    "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/main",
    "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/feature"
  ]
  # list of repository/branch references allowed to assume the role
  subject_claims = length(var.github_subject_claims) > 0 ? var.github_subject_claims : local.default_subjects

  # Determine which OIDC provider ARN to use to avoid duplication
  created_oidc_provider_arn = try(aws_iam_openid_connect_provider.github[0].arn, "")
  oidc_provider_arn         = var.existing_oidc_provider_arn != "" ? var.existing_oidc_provider_arn : local.created_oidc_provider_arn
}

# Create the OIDC provider if does not exist
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub's OIDC provider TLS certificate thumbprint (as of 2024-06-10)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = local.module_tags
}

# IAM Role for GitHub Actions to assume via OIDC
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.subject_claims
    }
  }
}

# Create the IAM Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions" {
  name               = "${var.name_prefix}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "Role assumed by GitHub Actions via OIDC for CI/CD."

  tags = local.module_tags

  lifecycle {
    precondition {
      # Only this repository can assume it
      condition     = local.oidc_provider_arn != ""
      error_message = "A GitHub OIDC provider ARN must be supplied either by creating one (create_oidc_provider=true) or via existing_oidc_provider_arn."
    }
  }
}

# Only for attaching managed policies
resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}

# Only for attaching inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.github_actions.id
  policy = each.value
}
