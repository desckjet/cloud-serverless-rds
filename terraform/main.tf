locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Application = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "database" {
  source = "./modules/database"

  name_prefix             = local.name_prefix
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.private_subnet_ids
  security_group_ids      = module.network.database_security_group_ids
  instance_class          = var.db_instance_class
  engine_version          = var.db_engine_version
  multi_az                = var.enable_rds_multi_az
  database_name           = var.db_name
  iam_database_username   = var.iam_database_username
  iam_token_username      = var.iam_token_username
  serverless_min_capacity = var.aurora_min_capacity
  serverless_max_capacity = var.aurora_max_capacity
  tags                    = local.common_tags
}

module "lambda" {
  source = "./modules/lambda"

  name_prefix                   = local.name_prefix
  subnet_ids                    = module.network.lambda_subnet_ids
  database_proxy_endpoint       = module.database.proxy_endpoint
  database_name                 = var.db_name
  database_username             = module.database.iam_token_username
  database_security_group_id    = module.network.database_security_group_ids[0]
  additional_security_group_ids = module.network.lambda_security_group_ids
  vpc_id                        = module.network.vpc_id
  iam_policy_arns               = [module.database.iam_connect_policy_arn]
  tags                          = local.common_tags
}

# module "api_gateway" {
#   source = "./modules/api_gateway"

#   name_prefix          = local.name_prefix
#   lambda_invoke_arn    = module.lambda.function_arn
#   lambda_function_name = module.lambda.function_name
#   tags                 = local.common_tags
# }

module "github_oidc" {
  source = "./modules/github_oidc"

  name_prefix           = local.name_prefix
  github_owner          = var.github_owner
  github_repository     = var.github_repository
  github_subject_claims = var.github_subject_claims
  managed_policy_arns   = var.ci_managed_policy_arns
  inline_policies = {
    ci-minimal = data.aws_iam_policy_document.ci_minimal.json
  }
  create_oidc_provider       = var.create_github_oidc_provider
  existing_oidc_provider_arn = var.existing_github_oidc_provider_arn
  tags                       = local.common_tags
}

module "ec2_bastion" {
  source = "./modules/ec2"

  name_prefix        = local.name_prefix
  subnet_id          = module.network.private_subnet_ids[0]
  security_group_ids = [module.network.compute_security_group_id]
  instance_type      = var.ec2_instance_type
  iam_policies       = [module.database.iam_connect_policy_arn]
  tags               = local.common_tags
}
