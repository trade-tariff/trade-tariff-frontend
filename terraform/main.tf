module "service" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/ecs-service?ref=aws/ecs-service-v1.11.3"

  region = var.region

  service_name  = "frontend"
  service_count = var.service_count

  cluster_name              = "trade-tariff-cluster-${var.environment}"
  subnet_ids                = data.aws_subnets.private.ids
  security_groups           = [data.aws_security_group.this.id]
  target_group_arn          = data.aws_lb_target_group.this.arn
  cloudwatch_log_group_name = "platform-logs-${var.environment}"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity

  docker_image = data.aws_ssm_parameter.ecr_url.value
  docker_tag   = var.docker_tag
  skip_destroy = true

  container_port = 8080

  cpu    = var.cpu
  memory = var.memory

  execution_role_policy_arns = [
    aws_iam_policy.secrets.arn,
  ]

  task_role_policy_arns = [
    aws_iam_policy.emails.arn
  ]

  service_environment_config = [
    {
      name  = "PORT"
      value = "8080"
    },
    {
      name  = "API_SERVICE_BACKEND_URL_OPTIONS"
      value = jsonencode(local.api_service_backend_url_options)
    },
    {
      name  = "BASIC_AUTH"
      value = "false"
    },
    {
      name  = "BETA_SEARCH"
      value = var.environment == "production" ? "false" : "true"
    },
    {
      name  = "BETA_SEARCH_HEADING_STATISTICS_THRESHOLD"
      value = "3"
    },
    {
      name  = "BETA_SEARCH_SWITCHING_ENABLED"
      value = var.beta_search_enabled
    },
    {
      name  = "CORS_HOST"
      value = var.base_domain
    },
    {
      name  = "GOVUK_APP_DOMAIN"
      value = "${local.govuk_app_domain}.london.cloudapps.digital"
    },
    {
      name  = "GOVUK_WEBSITE_ROOT"
      value = "https://www.gov.uk"
    },
    {
      name  = "HOST"
      value = var.base_domain
    },
    {
      name  = "DUTY_CALCULATOR_BASE_URL"
      value = "https://${var.base_domain}/duty-calculator"
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
      name  = "NEW_RELIC_ENV"
      value = var.environment
    },
    {
      name  = "NEW_RELIC_DISTRIBUTED_TRACING_ENABLED"
      value = false
    },
    {
      name  = "NEW_RELIG_LOG"
      value = "stdout"
    },
    {
      name  = "RAILS_ENV"
      value = "production"
    },
    {
      name  = "RAILS_SERVE_STATIC_FILES"
      value = "true"
    },
    {
      name  = "ROO_WIZARD"
      value = "true"
    },
    {
      name  = "RUBYOPT"
      value = "--enable-yjit"
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
      value = "Tariff Frontend [${title(var.environment)}] <no-reply@${var.base_domain}>"
    },
    {
      name  = "TARIFF_TO_EMAIL"
      value = "hmrc-trade-tariff-support-g@digital.hmrc.gov.uk"
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
      name  = "VCAP_APPLICATION"
      value = "{}"
    }
  ]

  service_secrets_config = [
    {
      name      = "REDIS_URL"
      valueFrom = data.aws_secretsmanager_secret.redis_connection_string.arn
    },
    {
      name      = "SECRET_KEY_BASE"
      valueFrom = data.aws_secretsmanager_secret.frontend_secret_key_base.arn
    },
  ]
}
