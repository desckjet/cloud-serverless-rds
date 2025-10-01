output "function_names" {
  description = "Map of Lambda function logical names to deployed function names."
  value       = { for key, fn in aws_lambda_function.this : key => fn.function_name }
}

output "function_arns" {
  description = "Map of Lambda function logical names to deployed function ARNs."
  value       = { for key, fn in aws_lambda_function.this : key => fn.arn }
}

output "function_invoke_arns" {
  description = "Map of Lambda function logical names to invoke ARNs for API integrations."
  value       = { for key, fn in aws_lambda_function.this : key => fn.invoke_arn }
}

output "security_group_id" {
  description = "Security group shared by all Lambda functions."
  value       = aws_security_group.lambda.id
}
