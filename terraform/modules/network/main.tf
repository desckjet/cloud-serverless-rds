# TODO: Implement VPC, subnets (public/private), routing, NAT gateway, and security groups.

locals {
  module_tags = merge(
    var.tags,
    {
      Module = "network"
    }
  )
}
