data "aws_region" "current" {}

locals {
  lambda_basic_execution_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  dynamodb_service                  = "dynamodb.${data.aws_region.current.name}.amazonaws.com"
  s3_service                        = "s3.${data.aws_region.current.name}.amazonaws.com"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- create_candidate ---

resource "aws_iam_role" "create_candidate" {
  name               = "${var.project_name}-create-candidate-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "create_candidate_basic_execution" {
  role       = aws_iam_role.create_candidate.name
  policy_arn = local.lambda_basic_execution_policy_arn
}

data "aws_iam_policy_document" "create_candidate" {
  statement {
    sid       = "DynamoDBPutItem"
    actions   = ["dynamodb:PutItem"]
    resources = [var.dynamodb_table_arn]
  }

  statement {
    sid       = "S3PutObject"
    actions   = ["s3:PutObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }

  statement {
    sid       = "KMSGenerateDataKeyViaS3"
    actions   = ["kms:GenerateDataKey"]
    resources = [var.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = [local.s3_service]
    }
  }

  statement {
    sid       = "KMSDecryptViaDynamoDB"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = [local.dynamodb_service]
    }
  }
}

resource "aws_iam_role_policy" "create_candidate" {
  name   = "${var.project_name}-create-candidate-policy"
  role   = aws_iam_role.create_candidate.id
  policy = data.aws_iam_policy_document.create_candidate.json
}

# --- get_candidate ---

resource "aws_iam_role" "get_candidate" {
  name               = "${var.project_name}-get-candidate-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "get_candidate_basic_execution" {
  role       = aws_iam_role.get_candidate.name
  policy_arn = local.lambda_basic_execution_policy_arn
}

data "aws_iam_policy_document" "get_candidate" {
  statement {
    sid       = "DynamoDBGetItem"
    actions   = ["dynamodb:GetItem"]
    resources = [var.dynamodb_table_arn]
  }

  statement {
    sid       = "S3GetObject"
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"]
  }

  statement {
    sid       = "KMSDecryptViaS3"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = [local.s3_service]
    }
  }

  statement {
    sid       = "KMSDecryptViaDynamoDB"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = [local.dynamodb_service]
    }
  }
}

resource "aws_iam_role_policy" "get_candidate" {
  name   = "${var.project_name}-get-candidate-policy"
  role   = aws_iam_role.get_candidate.id
  policy = data.aws_iam_policy_document.get_candidate.json
}

# --- list_candidates ---

resource "aws_iam_role" "list_candidates" {
  name               = "${var.project_name}-list-candidates-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "list_candidates_basic_execution" {
  role       = aws_iam_role.list_candidates.name
  policy_arn = local.lambda_basic_execution_policy_arn
}

data "aws_iam_policy_document" "list_candidates" {
  statement {
    sid       = "DynamoDBQueryGSI"
    actions   = ["dynamodb:Query"]
    resources = ["${var.dynamodb_table_arn}/index/${var.dynamodb_gsi_name}"]
  }

  statement {
    sid       = "KMSDecryptViaDynamoDB"
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = [local.dynamodb_service]
    }
  }
}

resource "aws_iam_role_policy" "list_candidates" {
  name   = "${var.project_name}-list-candidates-policy"
  role   = aws_iam_role.list_candidates.id
  policy = data.aws_iam_policy_document.list_candidates.json
}
