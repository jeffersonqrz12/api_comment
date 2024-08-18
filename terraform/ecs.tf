resource "aws_ecs_cluster" "api_comment_cluster" {
  name = "api-comment-cluster"
}


resource "aws_ecs_task_definition" "api_comment_task" {
  family                   = "api-comment-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "ecs_api"
      image     = "${aws_ecr_repository.api_comment_repo.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
depends_on = [aws_ecr_repository.api_comment_repo]
}

resource "aws_ecs_service" "api_comment_service" {
  name            = "api_comment_service"
  cluster         = aws_ecs_cluster.api_comment_cluster.id
  task_definition = aws_ecs_task_definition.api_comment_task.arn
  desired_count   = 1  
  launch_type     = "FARGATE"

 load_balancer {
   target_group_arn = aws_lb_target_group.
   container_name = "api_comment_service"
   container_port = 5000
  }
}
