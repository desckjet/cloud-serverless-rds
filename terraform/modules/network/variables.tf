variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block to assign to the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks allocated to public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks allocated to private subnets."
  type        = list(string)
}

variable "tags" {
  description = "Tags to propagate to managed resources."
  type        = map(string)
}
