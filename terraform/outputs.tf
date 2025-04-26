# Output the ALB DNS name
output "alb_dns_name" {
  value       = aws_lb.survey_alb.dns_name
  description = "The DNS name of the load balancer"
}

# Output the ECR repository URLs
output "frontend_repository_url" {
  value       = aws_ecr_repository.frontend_repo.repository_url
  description = "The URL of the ECR repository for the frontend"
}

output "backend_repository_url" {
  value       = aws_ecr_repository.backend_repo.repository_url
  description = "The URL of the ECR repository for the backend"
}