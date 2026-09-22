variable "project_name" {
  description = "Project name, used to build the key alias."
  type        = string
}

variable "environment" {
  description = "Deployment environment, used to build the key alias."
  type        = string
}
