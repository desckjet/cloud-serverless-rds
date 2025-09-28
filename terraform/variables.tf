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

variable "state_bucket_name" {
  description = "Optional override for the S3 bucket name storing Terraform state. Leave empty to use project/environment defaults."
  type        = string
  default     = ""
}

variable "state_bucket_force_destroy" {
  description = "Allow Terraform to delete the state bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name without owner."
  type        = string
}

variable "github_subject_claims" {
  description = "List of allowed subject claims (e.g. repo:org/repo:ref:refs/heads/main) for GitHub Actions OIDC role."
  type        = list(string)
  default     = []
}

variable "ci_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the GitHub Actions role."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]
}

variable "ci_tester_principals" {
  description = "List of IAM principal ARNs allowed to assume the CI tester role when create_ci_tester_role is true."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.ci_tester_principals) > 0
    error_message = "ci_tester_principals must contain at least one principal."
  }
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider in AWS (disable if already exists)."
  type        = bool
  default     = true
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN to reuse when create_github_oidc_provider is false."
  type        = string
  default     = ""
}
