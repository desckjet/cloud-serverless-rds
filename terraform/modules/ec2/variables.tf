variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the EC2 instance will reside."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the EC2 instance."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the bastion/utility host."
  type        = string
  default     = "t3.nano"
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
}

variable "iam_policies" {
  description = "List of IAM policy ARNs to attach to the instance role."
  type        = list(string)
  default     = []
}
