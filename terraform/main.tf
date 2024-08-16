provider "aws" {
  region = "us-east-1"
}

# Criar uma VPC
resource "aws_vpc" "apivpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Subnet pública na zona us-east-1a
resource "aws_subnet" "apisub_publica" {
  vpc_id                  = aws_vpc.apivpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-a"
  }
}

# Subnet pública na zona us-east-1b
resource "aws_subnet" "apisub_publicb" {
  vpc_id                  = aws_vpc.apivpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-b"
  }
}

# Criar um Internet Gateway
resource "aws_internet_gateway" "api_gateway" {
  vpc_id = aws_vpc.apivpc.id
  tags = {
    Name = "api-gateway"
  }
}

# Criar uma tabela de rotas
resource "aws_route_table" "api_route" {
  vpc_id = aws_vpc.apivpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.api_gateway.id
  }
}

# Associar a tabela de rotas às subnets
resource "aws_route_table_association" "publica_association" {
  subnet_id      = aws_subnet.apisub_publica.id
  route_table_id = aws_route_table.api_route.id
}

resource "aws_route_table_association" "publicb_association" {
  subnet_id      = aws_subnet.apisub_publicb.id
  route_table_id = aws_route_table.api_route.id
}

# Criar o repositório ECR
resource "aws_ecr_repository" "api_comment" {
  name = "api-comment-repo"
}

# Criar um ALB (Application Load Balancer)
resource "aws_lb" "api_alb" {
  name               = "api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.securityapi.id]
  subnets            = [
    aws_subnet.apisub_publica.id,
    aws_subnet.apisub_publicb.id
  ]
  enable_deletion_protection = false
  idle_timeout               = 60
  drop_invalid_header_fields = true
}

# Criar um Listener para o ALB
resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Healthy"
      status_code  = "200"
    }
  }
}

# Criar um Target Group
resource "aws_lb_target_group" "api_target_group" {
  name     = "api-target-group"
  port     = 5000
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

# Criar um Grupo de Segurança
resource "aws_security_group" "securityapi" {
  vpc_id = aws_vpc.apivpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar um Cluster ECS
resource "aws_ecs_cluster" "api_comment_cluster" {
  name = "api-comment-cluster"
}

# Criar uma Role para o ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role      = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Definir a Task Definition do ECS
resource "aws_ecs_task_definition" "api_comment_task" {
  family                   = "api-comment-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "api_comment_service"
      image     = "${aws_ecr_repository.api_comment.repository_url}:latest"
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
}

# Criar o Serviço ECS
resource "aws_ecs_service" "api_comment_service" {
  name            = "api_comment_service"
  cluster         = aws_ecs_cluster.api_comment_cluster.id
  task_definition = aws_ecs_task_definition.api_comment_task.arn
  desired_count   = 1  
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.apisub_publica.id, aws_subnet.apisub_publicb.id]
    security_groups  = [aws_security_group.securityapi.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_target_group.arn
    container_name   = "api_comment_service"
    container_port   = 5000
  }

  deployment_controller {
    type = "ECS"
  }
}

# Criar métricas e alarmes CloudWatch para CPU e disponibilidade
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name                = "high-cpu-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.api_comment_cluster.name
    ServiceName = aws_ecs_service.api_comment_service.name
  }

  alarm_description = "Alarm when CPU utilization exceeds 80%"
}

resource "aws_cloudwatch_metric_alarm" "api_availability" {
  alarm_name                = "api-availability"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 2
  metric_name               = "UnhealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1

  dimensions = {
    TargetGroup = aws_lb_target_group.api_target_group.name
    LoadBalancer = aws_lb.api_alb.name
  }

  alarm_description = "Alarm when the number of unhealthy hosts exceeds 1"
}
