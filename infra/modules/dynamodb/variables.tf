variable "table_name" {
  description = "Name of the candidates DynamoDB table."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for server-side encryption."
  type        = string
}
