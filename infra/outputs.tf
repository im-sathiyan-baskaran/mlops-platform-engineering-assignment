output "registry_url" {
  value = split("/", aws_ecr_repository.chart.repository_url)[0]
}

output "chart_repository_url" {
  value = aws_ecr_repository.chart.repository_url
}

output "publisher_role_arn" {
  description = "Store as the GitHub repo variable AWS_ROLE_ARN (not a secret)"
  value       = aws_iam_role.chart_publisher.arn
}