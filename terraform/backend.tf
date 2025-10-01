locals {
  backend_name        = "${var.project_name}-${var.environment}"
  backend_bucket_name = var.state_bucket_name != "" ? var.state_bucket_name : "${local.backend_name}-tfstate"
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = local.backend_bucket_name
  force_destroy = var.state_bucket_force_destroy

  tags = merge(
    {
      Name        = "${local.backend_name}-tfstate"
      ManagedBy   = "terraform"
      Component   = "tf-backend"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
