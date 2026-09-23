output "user_pool_id" {
  description = "ID of the Cognito user pool."
  value       = aws_cognito_user_pool.candidates_api.id
}

output "user_pool_domain" {
  description = "Cognito domain prefix, used to build the token endpoint URL."
  value       = aws_cognito_user_pool_domain.candidates_api.domain
}

output "resource_server_identifier" {
  description = "Identifier of the Candidates API resource server."
  value       = aws_cognito_resource_server.candidates_api.identifier
}

output "app_client_id" {
  description = "ID of the Cognito app client."
  value       = aws_cognito_user_pool_client.candidates_api.id
}

output "app_client_secret" {
  description = "Secret of the Cognito app client."
  value       = aws_cognito_user_pool_client.candidates_api.client_secret
  sensitive   = true
}
