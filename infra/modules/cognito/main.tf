# Machine-to-machine only: no human users, the pool only backs the OAuth2 server.
resource "aws_cognito_user_pool" "candidates_api" {
  name = "${var.project_name}-user-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_domain" "candidates_api" {
  domain       = "${var.project_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.candidates_api.id
}

resource "aws_cognito_resource_server" "candidates_api" {
  identifier   = "candidates-api"
  name         = "Candidates API"
  user_pool_id = aws_cognito_user_pool.candidates_api.id

  scope {
    scope_name        = "write"
    scope_description = "Create candidates"
  }

  scope {
    scope_name        = "read"
    scope_description = "Read candidates"
  }
}

resource "aws_cognito_user_pool_client" "candidates_api" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.candidates_api.id

  generate_secret                      = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  # Referencing scope_identifiers ("candidates-api/write", "candidates-api/read")
  # makes Terraform create the resource server before the client.
  allowed_oauth_scopes         = aws_cognito_resource_server.candidates_api.scope_identifiers
  supported_identity_providers = ["COGNITO"]
}
