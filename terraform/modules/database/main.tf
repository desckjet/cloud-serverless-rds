# TODO: Implement PostgreSQL RDS instance (or alternative backend) with subnet group and security groups.

locals {
  module_tags = merge(
    var.tags,
    {
      Module = "database"
    }
  )
}
