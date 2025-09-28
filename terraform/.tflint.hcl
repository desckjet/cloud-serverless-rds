config {
  terraform_version = "1.13.3"
  module            = true
}

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

override "aws_instance_invalid_type" {
  enabled = false
}
