variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

data "aws_ecr_repository" "app_repo" {
  name = "api.comment"  
}

output "app_image_url" {
  value = "${data.aws_ecr_repository.app_repo.repository_url}:latest"
}


variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  default     = "api_comment-cluster"
}

variable "ecs_service_name" {
  description = "ECS Service name"
  default     = "api_coment-service"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  default     = "api.comment"
}
