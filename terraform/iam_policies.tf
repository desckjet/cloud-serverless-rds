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

  # statement {
  #   sid = "TerraformIAMRead"
  #   actions = [
  #     "iam:GetRole",
  #     "iam:GetRolePolicy",
  #     "iam:ListRoles",
  #     "iam:ListRolePolicies",
  #     "iam:GetOpenIDConnectProvider",
  #     "iam:ListAttachedRolePolicies"
  #   ]
  #   resources = ["*"]
  # }

  # statement {
  #   sid       = "TerraformEC2Read"
  #   actions   = ["ec2:Describe*"]
  #   resources = ["*"]
  # }
}
