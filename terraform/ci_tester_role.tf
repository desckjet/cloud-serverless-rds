data "aws_iam_policy_document" "ci_tester_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.ci_tester_principals
    }
  }
}

resource "aws_iam_role" "ci_tester" {
  name               = "${local.name_prefix}-ci-tester"
  assume_role_policy = data.aws_iam_policy_document.ci_tester_trust.json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "ci_tester_inline" {
  name   = "ci-minimal"
  role   = aws_iam_role.ci_tester.id
  policy = data.aws_iam_policy_document.ci_minimal.json
}

resource "aws_iam_role_policy_attachment" "ci_tester_managed" {
  for_each = toset(var.ci_managed_policy_arns)

  role       = aws_iam_role.ci_tester.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "ci_tester_rds_connect" {
  role       = aws_iam_role.ci_tester.name
  policy_arn = module.database.iam_connect_policy_arn
}
