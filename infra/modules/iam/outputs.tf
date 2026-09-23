output "create_candidate_role_arn" {
  description = "ARN of the IAM role for the create_candidate Lambda."
  value       = aws_iam_role.create_candidate.arn
}

output "get_candidate_role_arn" {
  description = "ARN of the IAM role for the get_candidate Lambda."
  value       = aws_iam_role.get_candidate.arn
}

output "list_candidates_role_arn" {
  description = "ARN of the IAM role for the list_candidates Lambda."
  value       = aws_iam_role.list_candidates.arn
}
