variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda integration."
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function for IAM permission attachments."
  type        = string
}

variable "stage_name" {
  description = "Deployment stage name for the API Gateway."
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags to propagate to managed resources."
  type        = map(string)
}
