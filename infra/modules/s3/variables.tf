variable "bucket_name" {
  description = "Name of the S3 bucket storing candidate CVs."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for server-side encryption."
  type        = string
}
