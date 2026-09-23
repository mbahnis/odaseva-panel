output "table_name" {
  description = "Name of the candidates DynamoDB table."
  value       = aws_dynamodb_table.candidates_table.name
}

output "table_arn" {
  description = "ARN of the candidates DynamoDB table."
  value       = aws_dynamodb_table.candidates_table.arn
}

output "gsi_name" {
  description = "Name of the global secondary index on specialty."
  value       = local.gsi_name
}
