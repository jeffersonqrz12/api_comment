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

# Associar a tabela de rotas à subnet pública apisub_publica
resource "aws_route_table_association" "publica_association" {
  subnet_id      = aws_subnet.apisub_publica.id
  route_table_id = aws_route_table.api_route.id
}

# Associar a tabela de rotas à subnet pública apisub_publicb
resource "aws_route_table_association" "publicb_association" {
  subnet_id      = aws_subnet.apisub_publicb.id
  route_table_id = aws_route_table.api_route.id
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

resource "aws_ecr_repository" "api-comment" {
name = var.ecr_repository_name
}


#Application Load Balancer (ALB)
resource "aws_lb" "api_alb" {
  name               = "api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.securityapi.id]
  subnets            = [
    aws_subnet.apisub_publica.id,
    aws_subnet.apisub_publicb.id]

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



# Configuração do Cluster ECS
resource "aws_ecs_cluster" "api_comment-cluster" {
  name = var.ecs_cluster_name
}


resource "aws_ecs_service" "api_comment-service" {
  name            = "api_comment-service"
  cluster         = aws_ecs_cluster.api_comment-cluster.id
  task_definition = aws_ecs_task_definition.api-comment-task.arn
  desired_count   = 1  
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.apisub_publica.id]
    security_groups  = [aws_security_group.securityapi.id]
    assign_public_ip = true
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.api_target_group.arn
    container_name   = "api_comment-service"
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }
}

# Criar um Target Group
resource "aws_lb_target_group" "api_target_group" {
  name     = "api-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.apivpc.id

target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }
}

# Role e Policy para ECS
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

# Configuração da Task Definition ECS
resource "aws_ecs_task_definition" "api-comment-task" {
  family                   = "api-comment-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "api_comment-service"
      image     = "${aws_ecr_repository.api-comment.repository_url}:latest"
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
          awslogs-group         = aws_cloudwatch_log_group.apicomment_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Configuração do Grupo de Logs para a Task Definition
resource "aws_cloudwatch_log_group" "apicomment_logs" {
  name = "/ecs/api-comment"
}

resource "aws_cloudwatch_log_group" "apicommentlog" {
  name = "/ecs/apicomment-log"
}


