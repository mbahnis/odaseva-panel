# Root-level outputs are added here as each module exposes them.
output "cognito_user_pool_domain" {
  description = "Cognito hosted domain, used to build the OAuth2 token endpoint URL."
  value       = module.cognito.user_pool_domain
}

output "cognito_app_client_id" {
  description = "App client ID for the Client Credentials flow."
  value       = module.cognito.app_client_id
}

output "cognito_app_client_secret" {
  description = "App client secret for the Client Credentials flow."
  value       = module.cognito.app_client_secret
  sensitive   = true
}

output "api_endpoint" {
  description = "Base URL of the HTTP API."
  value       = module.api_gateway.api_endpoint
}
