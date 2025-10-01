locals {
  module_tags = merge(
    var.tags,
    {
      Module = "lambda"
    }
  )

  lambda_functions = {
    get = {
      description = "Retrieve animals entries"
      handler     = "handlers.get.lambda_handler"
    }
    post = {
      description = "Create or update animals entries"
      handler     = "handlers.post.lambda_handler"
    }
    delete = {
      description = "Delete animals entries"
      handler     = "handlers.delete.lambda_handler"
    }
  }

  base_environment = {
    DB_HOST     = var.database_proxy_endpoint
    DB_NAME     = var.database_name
    DB_PORT     = "5432"
    DB_USERNAME = var.database_username
  }

  source_dir   = "${path.module}/src"
  build_dir    = "${path.module}/build"
  package_dir  = "${local.build_dir}/package"
  archive_path = "${local.build_dir}/animals_lambda.zip"

  source_files = fileset(local.source_dir, "**")
  source_hash  = sha256(join("", [for file in local.source_files : filesha256("${local.source_dir}/${file}")]))
}

resource "null_resource" "package" {
  triggers = {
    requirements = filemd5("${path.module}/requirements.txt")
    source       = local.source_hash
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command     = <<-EOT
      set -euo pipefail
      rm -rf "${local.package_dir}"
      mkdir -p "${local.package_dir}"
      cp -R "${local.source_dir}/." "${local.package_dir}"
      python3 -m pip install --upgrade --no-cache-dir -r "${path.module}/requirements.txt" --target "${local.package_dir}"
      find "${local.package_dir}" -name '__pycache__' -type d -prune -exec rm -rf {} +
    EOT
  }
}

data "archive_file" "bundle" {
  type        = "zip"
  source_dir  = local.package_dir
  output_path = local.archive_path

  depends_on = [null_resource.package]
}

resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.iam_policy_arns)

  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}

resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda-sg"
  vpc_id      = var.vpc_id
  description = "Shared security group for Lambda functions"

  egress {
    description     = "Allow PostgreSQL traffic to the database security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.database_security_group_id]
  }

  egress {
    description = "Allow HTTPS egress for AWS service access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-lambda-sg"
  })
}

resource "aws_security_group_rule" "database_ingress" {
  description              = "Allow Lambda functions to reach the database"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.lambda.id
}

resource "aws_lambda_function" "this" {
  for_each = local.lambda_functions

  function_name = "${var.name_prefix}-${each.key}-lambda"
  description   = each.value.description
  role          = aws_iam_role.lambda.arn
  handler       = each.value.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  filename         = data.archive_file.bundle.output_path
  source_code_hash = data.archive_file.bundle.output_base64sha256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = concat([aws_security_group.lambda.id], var.additional_security_group_ids)
  }

  environment {
    variables = merge(local.base_environment, lookup(each.value, "environment", {}))
  }

  tags = merge(local.module_tags, {
    Name   = "${var.name_prefix}-${each.key}-lambda"
    Lambda = each.key
  })

  depends_on = [aws_security_group_rule.database_ingress]
}
