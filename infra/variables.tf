variable "aws_region" {
  description = "AWS region where resources are deployed."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Project name, used for resource naming and tagging."
  type        = string
  default     = "odaseva-panel"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev-odaseva-demo"
}
