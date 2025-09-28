locals {
  ci_tester_enabled = var.create_ci_tester_role && length(var.ci_tester_principals) > 0
}

data "aws_iam_policy_document" "ci_tester_trust" {
  count = local.ci_tester_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.ci_tester_principals
    }
  }
}

resource "aws_iam_role" "ci_tester" {
  count              = local.ci_tester_enabled ? 1 : 0
  name               = "${local.name_prefix}-ci-tester"
  assume_role_policy = data.aws_iam_policy_document.ci_tester_trust[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "ci_tester_inline" {
  count  = local.ci_tester_enabled ? 1 : 0
  name   = "ci-minimal"
  role   = aws_iam_role.ci_tester[0].id
  policy = data.aws_iam_policy_document.ci_minimal.json
}

resource "aws_iam_role_policy_attachment" "ci_tester_managed" {
  for_each = local.ci_tester_enabled ? toset(var.ci_managed_policy_arns) : toset([])

  role       = aws_iam_role.ci_tester[0].name
  policy_arn = each.value
}
