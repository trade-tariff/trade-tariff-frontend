module "service" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/ecs-service?ref=aws/ecs-service-v1.1.0"

  environment = var.environment
  region      = var.region

  service_name  = "frontend"
  service_count = var.service_count

  cluster_name       = "trade-tariff-cluster-${var.environment}"
  execution_role_arn = data.aws_iam_role.ecs_execution_role.arn
  task_role_arn      = data.aws_iam_role.ecs_task_role.arn
  subnet_ids         = data.aws_subnets.private.ids
  security_groups    = [data.aws_security_group.this.arn]
  target_group_arn   = data.aws_lb_target_group.this.arn

  min_capacity = 1
  max_capacity = 5

  docker_image = ""
  docker_tag   = var.docker_tag
  skip_destroy = true

  service_environment_config = [
    {
      name  = "BETA_SEARCH"
      value = "true"
    },
    {
      name  = "BETA_SEARCH_HEADING_STATISTICS_THRESHOLD"
      value = "3"
    },
    {
      name  = "BETA_SEARCH_SWITCHING_ENABLED"
      value = "true"
    },
    {
      name  = "CORS_HOST"
      value = var.base_domain
    },
    {
      name  = "HOST"
      value = var.base_domain
    },
    {
      name  = "DUTY_CALCULATOR_BASE_URL"
      value = "${var.base_domain}/duty-calculator"
    },
    {
      name  = "MALLOC_ARENA_MAX"
      value = "2"
    },
    {
      name  = "MAX_THREADS"
      value = "6"
    },
    {
      name  = "NEW_RELIC_APP_NAME"
      value = "tariff-frontend-${var.environment}"
    },
    {
      name  = "ROO_WIZARD"
      value = "true"
    },
    {
      name  = "SEARCH_BANNER"
      value = "false"
    },
    {
      name  = "SERVICE_DEFAULT"
      value = "uk"
    },
    {
      name  = "STW_URI"
      value = "https://check-how-to-import-export-goods.service.gov.uk/import/check-licences-certificates-and-other-restrictions"
    },
    {
      name  = "TARIFF_API_VERSION"
      value = "2"
    },
    {
      name  = "TARIFF_FROM_EMAIL"
      value = "Tariff Frontend [${title(var.environment)}] <no-reply@trade-tariff.service.gov.uk>"
    },
    {
      name  = "TARIFF_TO_EMAIL"
      value = "trade-tariff-support@enginegroup.com"
    },
    {
      name  = "WEB_CONCURRENCY"
      value = "6"
    },
    {
      name  = "WEBCHAT_URL"
      value = "https://www.tax.service.gov.uk/ask-hmrc/chat/trade-tariff"
    },
    {
      name  = "WELSH"
      value = "true"
    }
  ]

  service_secrets_config = [
    {
      name      = "REDIS_URL"
      valueFrom = data.aws_secretsmanager_secret.secret.arn
    }
  ]
}
