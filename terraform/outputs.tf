output "api_gateway_invoke_url" {
  description = "Invoke URL for the deployed API Gateway stage."
  value       = module.api_gateway.invoke_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function handling API requests."
  value       = module.lambda.function_name
}

output "database_endpoint" {
  description = "Writer endpoint for the Aurora PostgreSQL cluster."
  value       = module.database.endpoint
}

output "database_reader_endpoint" {
  description = "Read-only endpoint distributing connections across Aurora replicas."
  value       = module.database.reader_endpoint
}

output "database_proxy_endpoint" {
  description = "Endpoint of the RDS Proxy configured with IAM authentication."
  value       = module.database.proxy_endpoint
}

output "database_credentials_secret_arn" {
  description = "Secrets Manager ARN containing the managed master credentials."
  value       = module.database.credentials_secret_arn
}

output "database_master_username" {
  description = "Master database username managed through Secrets Manager."
  value       = module.database.iam_database_username
}

output "database_iam_token_username" {
  description = "Database username dedicated for IAM token based authentication."
  value       = module.database.iam_token_username
}

output "state_bucket_name" {
  description = "Name of the S3 bucket that stores the Terraform state."
  value       = aws_s3_bucket.tf_state.id
}

output "github_actions_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions via OIDC for CI/CD."
  value       = module.github_oidc.role_arn
}

output "github_oidc_provider_arn" {
  description = "OIDC provider ARN used for GitHub Actions federation."
  value       = module.github_oidc.oidc_provider_arn
}

output "ci_tester_role_arn" {
  description = "IAM role ARN for local testing with GitHub Actions permissions."
  value       = aws_iam_role.ci_tester.arn
}

output "ec2_instance_id" {
  description = "Instance ID of the SSM-managed EC2 utility host."
  value       = module.ec2_bastion.instance_id
}

output "ec2_iam_role_arn" {
  description = "IAM role ARN attached to the EC2 utility host (includes SSM and RDS connect permissions)."
  value       = module.ec2_bastion.iam_role_arn
}
