output "bucket_name" {
  description = "Name of the S3 bucket storing candidate CVs."
  value       = aws_s3_bucket.cv_storage.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket storing candidate CVs."
  value       = aws_s3_bucket.cv_storage.arn
}
