locals {
  module_tags = merge(
    var.tags,
    {
      Module = "database"
    }
  )

  cluster_identifier = "${var.name_prefix}-aurora"
  proxy_name         = "${var.name_prefix}-aurora-proxy"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-db-subnet"
  })
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = local.cluster_identifier
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  engine_mode        = "provisioned"

  database_name                       = var.database_name
  master_username                     = var.iam_database_username
  manage_master_user_password         = true
  iam_database_authentication_enabled = true
  db_subnet_group_name                = aws_db_subnet_group.this.name
  vpc_security_group_ids              = var.security_group_ids
  storage_encrypted                   = true
  copy_tags_to_snapshot               = true
  deletion_protection                 = false
  enable_http_endpoint                = false
  skip_final_snapshot                 = true

  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_min_capacity
    max_capacity = var.serverless_max_capacity
  }

  tags = merge(local.module_tags, {
    Name = local.cluster_identifier
  })
}

resource "random_password" "iam_user_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret" "iam_token_user" {
  name = "${var.name_prefix}-${var.iam_token_username}-credentials"

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-${var.iam_token_username}-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "iam_token_user" {
  secret_id = aws_secretsmanager_secret.iam_token_user.id
  secret_string = jsonencode({
    username = var.iam_token_username
    password = random_password.iam_user_password.result
  })
}

locals {
  instance_count = var.multi_az ? 2 : 1
}

resource "aws_rds_cluster_instance" "this" {
  count               = local.instance_count
  identifier          = "${local.cluster_identifier}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  publicly_accessible = false

  tags = merge(local.module_tags, {
    Name = "${local.cluster_identifier}-${count.index + 1}"
  })
}

resource "aws_iam_role" "proxy" {
  name = "${var.name_prefix}-db-proxy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-db-proxy-role"
  })
}

resource "aws_iam_role_policy" "proxy_secrets_access" {
  name = "${var.name_prefix}-db-proxy-secret-access"
  role = aws_iam_role.proxy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_rds_cluster.this.master_user_secret[0].secret_arn,
          aws_secretsmanager_secret.iam_token_user.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = aws_rds_cluster.this.master_user_secret[0].kms_key_id
      }
    ]
  })
}

resource "aws_db_proxy" "this" {
  name                   = local.proxy_name
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  vpc_security_group_ids = var.security_group_ids
  vpc_subnet_ids         = var.subnet_ids
  role_arn               = aws_iam_role.proxy.arn

  auth {
    auth_scheme = "SECRETS"
    # Enable IAM authentication
    iam_auth    = "REQUIRED"
    secret_arn  = aws_rds_cluster.this.master_user_secret[0].secret_arn
    description = "Cluster master credential"
  }

  auth {
    auth_scheme = "SECRETS"
    # Enable IAM authentication
    iam_auth    = "REQUIRED"
    secret_arn  = aws_secretsmanager_secret.iam_token_user.arn
    description = "Additional application credential"
  }

  tags = merge(local.module_tags, {
    Name = local.proxy_name
  })
}

locals {
  proxy_resource_id = try(
    regex("db-proxy:(prx-[a-z0-9]+)$", aws_db_proxy.this.arn)[0],
    element(reverse(split(":", aws_db_proxy.this.arn)), 0)
  )
}

resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent      = 90
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

resource "aws_db_proxy_target" "cluster" {
  db_proxy_name         = aws_db_proxy.this.name
  target_group_name     = aws_db_proxy_default_target_group.this.name
  db_cluster_identifier = aws_rds_cluster.this.id

  depends_on = [aws_rds_cluster_instance.this]
}

resource "aws_iam_policy" "rds_connect" {
  name_prefix = "${var.name_prefix}-rds-connect-"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = ["rds-db:connect"],
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.this.cluster_resource_id}/${var.iam_token_username}",
          "arn:aws:rds-db:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:dbuser:${local.proxy_resource_id}/${var.iam_token_username}"
        ]
      }
    ]
  })
}
