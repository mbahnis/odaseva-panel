output "key_id" {
  description = "ID of the shared KMS key."
  value       = aws_kms_key.data_encryption.key_id
}

output "key_arn" {
  description = "ARN of the shared KMS key."
  value       = aws_kms_key.data_encryption.arn
}

output "alias_name" {
  description = "Name of the KMS key alias."
  value       = aws_kms_alias.data_encryption.name
}
