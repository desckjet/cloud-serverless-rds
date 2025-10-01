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

variable "db_engine_version" {
  description = "Database engine version for the Aurora PostgreSQL cluster."
  type        = string
  default     = "17.5"
}

variable "db_instance_class" {
  description = "Instance class to use for the Aurora cluster instances (use db.serverless for Serverless v2)."
  type        = string
  default     = "db.serverless"
}

variable "db_name" {
  description = "Logical database name created in the Aurora cluster."
  type        = string
  default     = "app"
}

variable "iam_database_username" {
  description = "Database username that will leverage IAM authentication."
  type        = string
  default     = "iam_db_user"
}

variable "iam_token_username" {
  description = "Dedicated database username used for IAM token authentication via RDS Proxy."
  type        = string
  default     = "iam_token_user"
}

variable "aurora_min_capacity" {
  description = "Aurora Serverless v2 minimum ACU capacity."
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Aurora Serverless v2 maximum ACU capacity."
  type        = number
  default     = 2
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
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess"
  ]
}

variable "ci_tester_principals" {
  description = "List of IAM principal ARNs allowed to assume the CI tester role."
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

variable "ec2_instance_type" {
  description = "Instance type for the SSM-managed EC2 utility host."
  type        = string
  default     = "t3.nano"
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN to reuse when create_github_oidc_provider is false."
  type        = string
  default     = ""
}
