output "vpc_id" {
  description = "Identifier of the provisioned VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs for public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs for private subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "lambda_subnet_ids" {
  description = "Private subnet IDs dedicated to the Lambda function."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "lambda_security_group_ids" {
  description = "Security group IDs applied to the Lambda function."
  value       = [aws_security_group.shared.id]
}

output "database_security_group_ids" {
  description = "Security group IDs applied to the database backend."
  value       = [aws_security_group.shared.id]
}

output "nat_gateway_ids" {
  description = "Identities of the NAT gateways for private subnet egress."
  value       = [for nat in aws_nat_gateway.nat : nat.id]
}
