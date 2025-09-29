output "instance_id" {
  description = "Identifier of the EC2 instance used for SSM port forwarding."
  value       = aws_instance.this.id
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the EC2 instance."
  value       = aws_iam_role.instance.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the EC2 instance."
  value       = aws_iam_role.instance.arn
}
