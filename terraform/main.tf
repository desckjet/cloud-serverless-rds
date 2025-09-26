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

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = module.network.database_security_group_ids
  instance_class     = var.db_instance_class
  engine_version     = var.db_engine_version
  multi_az           = var.enable_rds_multi_az
  tags               = local.common_tags
}

module "lambda" {
  source = "./modules/lambda"

  name_prefix          = local.name_prefix
  subnet_ids           = module.network.lambda_subnet_ids
  security_group_ids   = module.network.lambda_security_group_ids
  database_credentials = module.database.credentials_secret_arn
  vpc_id               = module.network.vpc_id
  tags                 = local.common_tags
}

module "api_gateway" {
  source = "./modules/api_gateway"

  name_prefix          = local.name_prefix
  lambda_invoke_arn    = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.common_tags
}
