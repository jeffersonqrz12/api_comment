output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.api.repository_url
}

output "load_balancer_dns_name" {
  description = "Nome DNS do Load Balancer"
  value       = aws_lb.api.dns_name
}
