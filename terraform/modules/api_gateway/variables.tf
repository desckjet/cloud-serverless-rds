variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "stage_name" {
  description = "Deployment stage name for the API Gateway."
  type        = string
  default     = "default"
}

variable "routes" {
  description = "Map of route configurations to integrate HTTP methods with Lambda functions."
  type = map(object({
    path                 = string
    method               = string
    lambda_function_name = string
    lambda_function_arn  = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for route in var.routes :
      length([
        for segment in split(trim(route.path, "/"), "/") : segment if segment != ""
      ]) <= 1
    ])
    error_message = "Routes may include at most one path segment (e.g., '/animals'). Nested paths are not currently supported."
  }

}

variable "tags" {
  description = "Tags to propagate to managed resources."
  type        = map(string)
}
