variable "project_name" {
  description = "Project name, used to name the IAM roles and policies."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the candidates DynamoDB table."
  type        = string
}

variable "dynamodb_gsi_name" {
  description = "Name of the global secondary index on specialty."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket storing candidate CVs."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the shared KMS key."
  type        = string
}
