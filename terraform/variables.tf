variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier used for tagging and naming."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project or application name used for shared resource prefixes."
  type        = string
  default     = "cloud-serverless-rds"
}

variable "vpc_cidr" {
  description = "CIDR block to assign to the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

variable "db_instance_class" {
  description = "Instance class to use for the database backend."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_engine_version" {
  description = "Database engine version for RDS."
  type        = string
  default     = "15.4"
}

variable "enable_rds_multi_az" {
  description = "Enable Multi-AZ deployments for the RDS instance."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
