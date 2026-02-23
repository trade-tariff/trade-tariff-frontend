module "service" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/ecs-service?ref=aws/ecs-service-v1.18.2"

  region = var.region

  service_name  = "frontend"
  service_count = var.service_count

  cluster_name              = "trade-tariff-cluster-${var.environment}"
  subnet_ids                = data.aws_subnets.private.ids
  security_groups           = [data.aws_security_group.this.id]
  target_group_arn          = data.aws_lb_target_group.this.arn
  cloudwatch_log_group_name = "platform-logs-${var.environment}"

  docker_image = "382373577178.dkr.ecr.eu-west-2.amazonaws.com/tariff-frontend-production"
  docker_tag   = var.docker_tag
  skip_destroy = true

  container_port = 8084

  cpu    = var.cpu
  memory = var.memory

  task_role_policy_arns = [aws_iam_policy.task.arn]
  enable_ecs_exec       = true

  service_environment_config = local.frontend_service_env_vars

  has_autoscaler = local.has_autoscaler
  min_capacity   = var.min_capacity
  max_capacity   = var.max_capacity

  autoscaling_metrics = {
    cpu = {
      metric_type  = "ECSServiceAverageCPUUtilization"
      target_value = 55
    }
    memory = {
      metric_type  = "ECSServiceAverageMemoryUtilization"
      target_value = 70
    }
  }

  sns_topic_arns = [data.aws_sns_topic.slack_topic.arn]
}
