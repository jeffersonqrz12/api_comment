# Criar uma VPC
resource "aws_vpc" "apivpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# subnet pública
resource "aws_subnet" "apisub_publica" {
  vpc_id     = aws_vpc.apivpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-eas1-1"  
  map_public_ip_on_launch = true
}

#grupo de segurança
resource "aws_security_group" "securityapi" {
  vpc_id = aws_vpc.apivpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "repo-comment" {
name = var.ecr_repository_name

#Application Load Balancer (ALB)
resource "aws_lb" "api_alb" {
  name               = "api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.securityapi.id]
  subnets            = [aws_subnet.pisub_publica.id]

  enable_deletion_protection = false
  idle_timeout               = 60
  drop_invalid_header_fields = true
}

# listener para o ALB
resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "200 OK"
      status_code  = "200"
    }
  }
}

# Criar um Target Group
resource "aws_lb_target_group" "api_target_group" {
  name     = "api-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.apivpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }
}

resource "aws_ecs_cluster" 'apicomment-cluster" {
  name = var.ecs_cluster_name
}



resource "aws_ecs_task_definition" "apicomment.task" {
  family                = "apicomment-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"

  container_definitions = jsonencode([
    {
      name      = "apicomment-container"
      image     = "${aws_ecr_repository.repo-comment.repository_url}:latest"  
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
          awslogs-group         = "/ecs/api-comment"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]
}


resource "aws_ecs_service" "apicomment-serv" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.api_comment-cluster.id
  task_definition = aws_ecs_task_definition.api-comment-task.arn
  desired_count   = 1  
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.apisub_public.id]
    security_groups  = [aws_security_group.securityapi.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_target_group.arn
    container_name   = "api-comment"
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }

  autoscaling {
    min_capacity = 1
    max_capacity = 3
  }
}

resource "aws_cloudwatch_log_group" "apicommentlog" {
  name = "/ecs/apicomment-log"
}

# alrme para limite de cpu
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name                = "high-cpu-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "aplicação usando 80% do cpu"

  dimensions = {
    ClusterName = aws_ecs_cluster.api_comment-cluster.name
    ServiceName = aws_ecs_service.api_comment-service.name
  }

  alarm_actions = ["arn:aws:sns:us-east-1:927434173120:snsteste.fifo"]
}
