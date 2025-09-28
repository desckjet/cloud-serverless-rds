data "aws_iam_policy_document" "ci_minimal" {
  statement {
    sid = "TerraformStateBucket"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]
  }

  statement {
    sid = "TerraformIAM"
    actions = [
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
    ]
    resources = ["*"]
  }

  # statement {
  #   sid       = "TerraformEC2"
  #   actions   = ["ec2:Describe*"]
  #   resources = ["*"]
  # }
}
