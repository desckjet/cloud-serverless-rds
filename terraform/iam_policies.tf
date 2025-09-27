data "aws_iam_policy_document" "ci_minimal" {
  statement {
    sid = "TerraformStateBucket"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration"
    ]

    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]
  }

  statement {
    sid       = "TerraformNetworkingRead"
    actions   = ["ec2:Describe*", "iam:ListRoles", "iam:GetRole"]
    resources = ["*"]
  }
}
