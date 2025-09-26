output "vpc_id" {
  description = "Identifier of the provisioned VPC."
  value       = null
}

output "public_subnet_ids" {
  description = "IDs for public subnets."
  value       = []
}

output "private_subnet_ids" {
  description = "IDs for private subnets."
  value       = []
}

output "lambda_subnet_ids" {
  description = "Private subnet IDs dedicated to the Lambda function."
  value       = []
}

output "lambda_security_group_ids" {
  description = "Security group IDs applied to the Lambda function."
  value       = []
}

output "database_security_group_ids" {
  description = "Security group IDs applied to the database backend."
  value       = []
}

output "nat_gateway_ids" {
  description = "Identities of the NAT gateways for private subnet egress."
  value       = []
}
