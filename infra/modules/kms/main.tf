resource "aws_kms_key" "data_encryption" {
  description             = "Shared KMS key for odaseva-panel data encryption (DynamoDB, S3)"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "data_encryption" {
  name          = "alias/${var.project_name}-${var.environment}"
  target_key_id = aws_kms_key.data_encryption.key_id
}
