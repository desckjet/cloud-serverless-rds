output "rest_api_id" {
  description = "Identifier for the created REST API."
  value       = aws_api_gateway_rest_api.this.id
}

output "invoke_url" {
  description = "Invoke URL for the deployed API Gateway stage."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "execution_arn" {
  description = "Execution ARN for permission attachments."
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_name" {
  description = "Name of the deployed API Gateway stage."
  value       = aws_api_gateway_stage.this.stage_name
}
