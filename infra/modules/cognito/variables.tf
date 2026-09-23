variable "project_name" {
  description = "Project name, used to name the Cognito resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment, used to build the Cognito domain."
  type        = string
}
