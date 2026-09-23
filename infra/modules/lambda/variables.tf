variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "source_dir" {
  description = "Path to the directory containing the Lambda source code."
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role assumed by the Lambda function."
  type        = string
}

variable "environment_variables" {
  description = "Environment variables passed to the Lambda function."
  type        = map(string)
}

variable "timeout" {
  description = "Lambda timeout, in seconds."
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory size, in MB."
  type        = number
  default     = 128
}
