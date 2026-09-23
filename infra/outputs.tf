# Ce fichier accueillera les outputs des modules au fur et à mesure de leur création.

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
