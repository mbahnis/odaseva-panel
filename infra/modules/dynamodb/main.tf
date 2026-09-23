locals {
  gsi_name = "specialty-index"
}

resource "aws_dynamodb_table" "candidates_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "candidateId"

  attribute {
    name = "candidateId"
    type = "S"
  }

  attribute {
    name = "specialty"
    type = "S"
  }

  global_secondary_index {
    name            = local.gsi_name
    hash_key        = "specialty"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }
}
