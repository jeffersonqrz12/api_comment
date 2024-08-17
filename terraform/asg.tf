resource "aws_launch_configuration" "ecs_launch_config" {
  image_id              = "ami-002d6945033440b91"
  iam_instance_profile  = aws_iam_instance_profile.ecs_agent.name
  security_groups       = [aws_security_group.ecs_sg.id]
  user_data             = "#/bin/bash\necho ECS_CLUSTER=ecs_lab >> /etc/ecs/ecs.config"
  instance_type         = "t2.medium"
  key_name              = "mytestekey
}


resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "asg_terraform_ecs_lab"
  launch_configuration = aws_launch_configuration.ecs_launch_config.id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "EC2
  vpc_zone_identifier       = [aws_subnet.apisub_publica.id]
  target_group_arns = [aws_lb_api_target_group.arn]

  lifecycle {
    create_before_destroy = true
  }
}
