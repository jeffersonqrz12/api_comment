resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name                = "high-cpu-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "aplicação utilizando 80 por cento do cpu"

  dimensions = {
    ClusterName = aws_ecs_cluster.api_comment_cluster.name
    ServiceName = aws_ecs_service.api_comment_service.name
  }

  alarm_actions = ["arn:aws:sns:us-east-1:927420173806:teste.fifo"]
}
