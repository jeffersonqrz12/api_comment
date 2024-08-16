variable "region" {
  description = "A região AWS onde os recursos serão criados"
  default     = "us-east-1"
}

variable "ecr_repository_name" {
  description = "Nome do repositório ECR"
  default     = "my-api-repository"
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  default     = "my-ecs-cluster"
}

variable "ecs_service_name" {
  description = "Nome do serviço ECS"
  default     = "my-ecs-service"
}

variable "container_image" {
  description = "URL da imagem do container no ECR"
}

variable "container_port" {
  description = "Porta no container onde a aplicação escuta"
  default     = 5000
}

variable "desired_count" {
  description = "Número desejado de instâncias do serviço ECS"
  default     = 2
}
