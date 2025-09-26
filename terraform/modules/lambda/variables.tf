variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where the Lambda function will run."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to the Lambda function."
  type        = list(string)
}

variable "database_credentials" {
  description = "ARN of the secret containing database credentials."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier for the Lambda networking configuration."
  type        = string
}

variable "runtime" {
  description = "Runtime to use for the Lambda function."
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Handler entrypoint for the Lambda function."
  type        = string
  default     = "handler.lambda_handler"
}

variable "memory_size" {
  description = "Lambda memory allocation in MB."
  type        = number
  default     = 256
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
