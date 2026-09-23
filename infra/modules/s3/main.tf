resource "aws_s3_bucket" "cv_storage" {
  bucket = var.bucket_name
  force_destroy = true // security issue : used only for demo
}

resource "aws_s3_bucket_public_access_block" "cv_storage" {
  bucket = aws_s3_bucket.cv_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cv_storage" {
  bucket = aws_s3_bucket.cv_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "cv_storage" {
  bucket = aws_s3_bucket.cv_storage.id

  versioning_configuration {
    status = "Disabled"
  }
}
