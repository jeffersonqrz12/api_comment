resource "aws_ecr_repository" "api.comment" {
  name = var.ecr_repository_name
}

resource "aws_ecs_cluster" "api_comment-cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "api-comment-task" {
  family                = "api_comment-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"

  container_definitions = jsonencode([
    {
      name      = "api_comment"
      image     = var.app_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/api.comment"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api_coment-service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.api_comment-cluster.id
  task_definition = aws_ecs_task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets          = ["subnet-073ec42a65bae4bbf"]  # IDs das subnets
    security_groups  = ["sg-02ace99006012a132"]      # ID do security group
    assign_public_ip = true
  }

  launch_type = "FARGATE"
}


resource "aws_cloudwatch_log_group" "api_coment" {
  name = "/ecs/api-comment"
}
