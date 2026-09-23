variable "project_name" {
  description = "Project name, used to name the API resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region, used to build the Cognito issuer URL."
  type        = string
}

variable "cognito_user_pool_id" {
  description = "ID of the Cognito user pool issuing the access tokens."
  type        = string
}

variable "cognito_app_client_id" {
  description = "ID of the Cognito app client, used as the JWT audience."
  type        = string
}

variable "create_candidate_invoke_arn" {
  description = "Invoke ARN of the create_candidate Lambda."
  type        = string
}

variable "create_candidate_function_name" {
  description = "Name of the create_candidate Lambda."
  type        = string
}

variable "get_candidate_invoke_arn" {
  description = "Invoke ARN of the get_candidate Lambda."
  type        = string
}

variable "get_candidate_function_name" {
  description = "Name of the get_candidate Lambda."
  type        = string
}

variable "list_candidates_invoke_arn" {
  description = "Invoke ARN of the list_candidates Lambda."
  type        = string
}

variable "list_candidates_function_name" {
  description = "Name of the list_candidates Lambda."
  type        = string
}
