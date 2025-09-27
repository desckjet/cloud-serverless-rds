output "api_gateway_invoke_url" {
  description = "Invoke URL for the deployed API Gateway stage."
  value       = module.api_gateway.invoke_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function handling API requests."
  value       = module.lambda.function_name
}

output "database_endpoint" {
  description = "Connection endpoint for the database backend."
  value       = module.database.endpoint
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
