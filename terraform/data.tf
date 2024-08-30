data "aws_vpc" "vpc" {
  tags = { Name = "trade-tariff-${var.environment}-vpc" }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*private*"
  }
}

data "aws_lb_target_group" "this" {
  name = "frontend"
}

data "aws_lb_target_group" "beta" {
  name = "frontend-beta"
}

data "aws_security_group" "this" {
  name = "trade-tariff-ecs-security-group-${var.environment}"
}

data "aws_secretsmanager_secret" "redis_connection_string" {
  name = "redis-frontend-connection-string"
}

data "aws_secretsmanager_secret" "frontend_secret_key_base" {
  name = "frontend-secret-key-base"
}

data "aws_kms_key" "secretsmanager_key" {
  key_id = "alias/secretsmanager-key"
}

data "aws_ssm_parameter" "ecr_url" {
  name = "/${var.environment}/FRONTEND_ECR_URL"
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "frontend-sentry-dsn"
}

data "aws_secretsmanager_secret" "green_lanes_api_tokens" {
  name = "backend-green-lanes-api-tokens"
}

data "aws_secretsmanager_secret" "google_tag_manager_container_id" {
  name = "google_tag_manager_container_id"
}
