data "aws_vpc" "vpc" {
  tags = { Name = "trade_tariff_${var.environment}_vpc" }
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
  name = "trade-tariff-fe-tg-${var.environment}"
}

data "aws_security_group" "this" {
  name = "trade-tariff-alb-security-group-${var.environment}"
}

data "aws_iam_role" "ecs_execution_role" {
  name = "tariff-frontend-execution-role-${var.environment}"
}

data "aws_iam_role" "ecs_task_role" {
  name = "tariff-frontend-service-role-${var.environment}"
}

data "aws_secretsmanager_secret" "redis_connection_string" {
  name = "redis-connection-string"
}

