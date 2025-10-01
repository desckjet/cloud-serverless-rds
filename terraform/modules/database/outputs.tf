output "endpoint" {
  description = "Writer endpoint for the Aurora cluster."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint balancing across Aurora replicas."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "proxy_endpoint" {
  description = "Endpoint exposed by the RDS proxy."
  value       = aws_db_proxy.this.endpoint
}

output "credentials_secret_arn" {
  description = "Secrets Manager ARN containing the managed master credentials."
  value       = aws_rds_cluster.this.master_user_secret[0].secret_arn
}

output "resource_id" {
  description = "Unique cluster resource identifier used for IAM connect policies."
  value       = aws_rds_cluster.this.cluster_resource_id
}

output "iam_connect_policy_arn" {
  description = "IAM policy ARN granting rds-db:connect access for the IAM database user."
  value       = aws_iam_policy.rds_connect.arn
}

output "iam_database_username" {
  description = "Master database username managed via Secrets Manager."
  value       = var.iam_database_username
}

output "iam_token_username" {
  description = "Database username dedicated for IAM token authentication."
  value       = var.iam_token_username
}
