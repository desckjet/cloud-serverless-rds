# TODO: Implement API Gateway REST API, Lambda integration, deployment, and logging configuration.

locals {
  module_tags = merge(
    var.tags,
    {
      Module = "api-gateway"
    }
  )
}
