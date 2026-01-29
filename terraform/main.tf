module "service" {
  source = "git::https://github.com/trade-tariff/trade-tariff-platform-terraform-modules.git//aws/ecs-service?ref=HMRC-1766-edit-scaling"

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

  container_port = 8080

  cpu    = var.cpu
  memory = var.memory

  task_role_policy_arns = [aws_iam_policy.task.arn]
  enable_ecs_exec       = true

  service_environment_config = local.secret_env_vars

  has_autoscaler = local.has_autoscaler
  min_capacity   = var.min_capacity
  max_capacity   = var.max_capacity

  scale_out_cooldown      = 90
  scale_in_cooldown       = 300
  step_scale_out_cooldown = 120

  scheduled_actions_enabled = true
  scheduled_scaling_actions = {
    weekday_0700 = {
      schedule     = "cron(0 7 ? * MON-FRI *)" # 07:00 UTC on weekdays
      min_capacity = var.min_capacity
      max_capacity = var.max_capacity
    }
    weekend_0700 = {
      schedule     = "cron(0 7 ? * SAT,SUN *)" # 07:00 UTC on weekends
      min_capacity = 1
      max_capacity = 10
    }
  }

  sns_topic_arns = [data.aws_sns_topic.slack_topic.arn]
}
