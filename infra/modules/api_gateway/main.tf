resource "aws_apigatewayv2_api" "candidates" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

# Validates Cognito access tokens. Client Credentials tokens have no "aud" claim,
# so API Gateway matches the audience against their "client_id" claim instead.
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.candidates.id
  name             = "${var.project_name}-cognito-authorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_app_client_id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

# --- create_candidate ---

resource "aws_apigatewayv2_integration" "create_candidate" {
  api_id                 = aws_apigatewayv2_api.candidates.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.create_candidate_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_candidate" {
  api_id               = aws_apigatewayv2_api.candidates.id
  route_key            = "POST /candidates"
  target               = "integrations/${aws_apigatewayv2_integration.create_candidate.id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.cognito.id
  authorization_scopes = ["candidates-api/write"]
}

resource "aws_lambda_permission" "create_candidate" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.create_candidate_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.candidates.execution_arn}/*/*"
}

# --- get_candidate ---

resource "aws_apigatewayv2_integration" "get_candidate" {
  api_id                 = aws_apigatewayv2_api.candidates.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.get_candidate_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_candidate" {
  api_id               = aws_apigatewayv2_api.candidates.id
  route_key            = "GET /candidates/{candidateId}"
  target               = "integrations/${aws_apigatewayv2_integration.get_candidate.id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.cognito.id
  authorization_scopes = ["candidates-api/read"]
}

resource "aws_lambda_permission" "get_candidate" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.get_candidate_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.candidates.execution_arn}/*/*"
}

# --- list_candidates ---

resource "aws_apigatewayv2_integration" "list_candidates" {
  api_id                 = aws_apigatewayv2_api.candidates.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.list_candidates_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_candidates" {
  api_id               = aws_apigatewayv2_api.candidates.id
  route_key            = "GET /candidates"
  target               = "integrations/${aws_apigatewayv2_integration.list_candidates.id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.cognito.id
  authorization_scopes = ["candidates-api/read"]
}

resource "aws_lambda_permission" "list_candidates" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.list_candidates_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.candidates.execution_arn}/*/*"
}

# --- stage & access logs ---

resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.candidates.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }
}
