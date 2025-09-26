output "endpoint" {
  description = "Endpoint used by clients to reach the database backend."
  value       = null
}

output "credentials_secret_arn" {
  description = "ARN of the secret storing credentials for the backend."
  value       = null
}

output "resource_id" {
  description = "Unique identifier of the managed database resource."
  value       = null
}
