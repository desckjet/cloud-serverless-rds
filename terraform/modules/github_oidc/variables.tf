variable "name_prefix" {
  description = "Resource name prefix combining project and environment."
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources."
  type        = map(string)
  default     = {}
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
  validation {
    condition     = length(trimspace(var.github_owner)) > 0
    error_message = "github_owner must be provided and cannot be empty."
  }
}

variable "github_repository" {
  description = "GitHub repository name (without owner)."
  type        = string
  validation {
    condition     = length(trimspace(var.github_repository)) > 0
    error_message = "github_repository must be provided and cannot be empty."
  }
}

variable "github_subject_claims" {
  description = "List of subject claims allowed to assume the role (e.g. repo:org/repo:ref:refs/heads/main)."
  type        = list(string)
  default     = []
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the GitHub Actions role."
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of IAM policy names to JSON documents for inline policies attached to the role."
  type        = map(string)
  default     = {}
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider in this module. Disable if one already exists in the account."
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN to reuse instead of creating a new one."
  type        = string
  default     = ""
}
