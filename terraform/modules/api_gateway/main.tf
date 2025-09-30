locals {
  module_tags = merge(
    var.tags,
    {
      Module = "api-gateway"
    }
  )

  normalized_routes = {
    for key, route in var.routes :
    key => {
      path                 = trim(route.path, "/")
      method               = upper(route.method)
      lambda_function_name = route.lambda_function_name
      lambda_function_arn  = try(trimspace(route.lambda_function_arn), route.lambda_function_arn)
    }
  }

  unique_paths = distinct([for route in local.normalized_routes : route.path])

  path_resources = {
    for path in local.unique_paths :
    path => path
    if path != ""
  }
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.name_prefix}-api"
  description = "REST API exposing the animal Lambda functions"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-api"
  })
}

resource "aws_api_gateway_resource" "path" {
  for_each = local.path_resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value
}

resource "aws_api_gateway_method" "this" {
  for_each = local.normalized_routes

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.path == "" ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.path[each.value.path].id
  http_method   = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  for_each = aws_api_gateway_method.this

  rest_api_id = each.value.rest_api_id
  resource_id = each.value.resource_id
  http_method = each.value.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = format(
    "arn:%s:apigateway:%s:lambda:path/2015-03-31/functions/%s/invocations",
    data.aws_partition.current.partition,
    data.aws_region.current.name,
    local.normalized_routes[each.key].lambda_function_arn
  )
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = local.normalized_routes

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = format(
    "%s/%s/%s%s",
    aws_api_gateway_rest_api.this.execution_arn,
    var.stage_name,
    each.value.method,
    each.value.path == "" ? "" : "/${each.value.path}"
  )
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode({
      routes = local.normalized_routes
    }))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.lambda]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name

  tags = merge(local.module_tags, {
    Name = "${var.name_prefix}-${var.stage_name}-stage"
  })
}
