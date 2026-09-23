data "archive_file" "source" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.root}/.build/${var.function_name}.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  runtime          = "python3.13"
  handler          = "handler.lambda_handler"
  role             = var.role_arn
  filename         = data.archive_file.source.output_path
  source_code_hash = data.archive_file.source.output_base64sha256
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.environment_variables
  }

  # Ensure Terraform owns the log group before Lambda can auto-create it.
  depends_on = [aws_cloudwatch_log_group.lambda]
}
