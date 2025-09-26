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
