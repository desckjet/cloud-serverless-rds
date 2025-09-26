variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier where the database will run."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets used for the database subnet group."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups that allow database access."
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class or size for the database backend."
  type        = string
}

variable "engine_version" {
  description = "Version for the selected database engine."
  type        = string
}

variable "multi_az" {
  description = "Flag to enable Multi-AZ deployments."
  type        = bool
}

variable "tags" {
  description = "Tags to propagate to managed resources."
  type        = map(string)
}
