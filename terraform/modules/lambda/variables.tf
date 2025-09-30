variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets where the Lambda functions will run."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC identifier for the Lambda networking configuration."
  type        = string
}

variable "database_proxy_endpoint" {
  description = "Hostname of the RDS proxy for database connectivity."
  type        = string
}

variable "database_name" {
  description = "Logical database name to target within the cluster."
  type        = string
}

variable "database_username" {
  description = "Database username used for IAM-authenticated connections."
  type        = string
}

variable "database_security_group_id" {
  description = "Security group protecting the database, used to create ingress rules for Lambda."
  type        = string
}

variable "additional_security_group_ids" {
  description = "Optional security groups to attach alongside the managed Lambda security groups."
  type        = list(string)
  default     = []
}

variable "iam_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the Lambda execution role."
  type        = list(string)
  default     = []
}

variable "runtime" {
  description = "Runtime to use for the Lambda function package."
  type        = string
  default     = "python3.13"
}

variable "memory_size" {
  description = "Lambda memory allocation in MB."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to propagate to managed resources."
  type        = map(string)
}
