output "function_names" {
  description = "Map of Lambda function logical names to deployed function names."
  value       = { for key, fn in aws_lambda_function.this : key => fn.function_name }
}

output "function_arns" {
  description = "Map of Lambda function logical names to deployed function ARNs."
  value       = { for key, fn in aws_lambda_function.this : key => fn.arn }
}

output "security_group_id" {
  description = "Security group shared by all Lambda functions."
  value       = aws_security_group.lambda.id
}
