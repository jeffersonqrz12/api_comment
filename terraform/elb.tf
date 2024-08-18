resource "aws_lb" "api_alb" {
  name               = "api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg-api.id]
  subnets            = [
    aws_subnet.apisub_publica.id,
    aws_subnet.apisub_publicb.id
  ]
  enable_deletion_protection = false
  idle_timeout               = 60
  drop_invalid_header_fields = true

  tags = {
    Name = "alb-ecs-lab"
  }
}

resource "aws_lb_target_group" "api_target_group" {
  name        = "api-target-group"
  port        = 5000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.apivpc.id

  depends_on  = aws_lb.api_alb]

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }
}

resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_api_target_grou.arn
    
    }
  }
}





