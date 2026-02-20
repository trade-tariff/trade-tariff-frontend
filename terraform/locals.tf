locals {
  has_autoscaler = var.environment == "development" ? false : true
  secret_value   = try(data.aws_secretsmanager_secret_version.this.secret_string, "{}")
  secret_map     = jsondecode(local.secret_value)
  secret_env_vars = [
    for key, value in local.secret_map : {
      name  = key
      value = value
    }
  ]

  ecs_tls_env_vars = [
    {
      name      = "SSL_KEY_PEM"
      valueFrom = "${data.aws_secretsmanager_secret.ecs_tls_certificate.arn}:private_key::"
    },
    {
      name      = "SSL_CERT_PEM"
      valueFrom = "${data.aws_secretsmanager_secret.ecs_tls_certificate.arn}:certificate::"
    },
    {
      name  = "SSL_PORT"
      value = "8443"
    }
  ]

  frontend_service_env_vars = concat(local.secret_env_vars, local.ecs_tls_env_vars)
}
