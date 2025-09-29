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

variable "database_name" {
  description = "Initial database name to create within the cluster."
  type        = string
  default     = "app"
}

variable "iam_database_username" {
  description = "Database user that will leverage IAM authentication."
  type        = string
  default     = "iam_db_user"
}

variable "iam_token_username" {
  description = "Database username dedicated for IAM token authentication."
  type        = string
  default     = "iam_token_user"
}

variable "serverless_min_capacity" {
  description = "Aurora Serverless v2 minimum ACU capacity."
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "Aurora Serverless v2 maximum ACU capacity."
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags to propagate to managed resources."
  type        = map(string)
}
