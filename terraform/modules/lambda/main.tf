# TODO: Implement Lambda function, IAM role/policies, security group rules, and VPC attachment.

locals {
  module_tags = merge(
    var.tags,
    {
      Module = "lambda"
    }
  )
}
