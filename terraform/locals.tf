locals {
  # Cost allocation tags. Activate them in the Billing console so Cost Explorer
  # can group costs by component. The module copies them to each Fargate task.
  cost_allocation_tags = {
    Component = "frontend"
  }

  has_autoscaler = var.environment == "development" ? false : true
  secret_value   = try(data.aws_secretsmanager_secret_version.this.secret_string, "{}")

  # UAT: values that the common stack generates on each start.
  generated_env_vars = merge(
    { for name, secret in var.generated_secrets : name => data.aws_secretsmanager_secret_version.generated[secret].secret_string },
    { for name, parameter in var.generated_parameters : name => data.aws_ssm_parameter.generated[parameter].value },
  )

  secret_map = merge(jsondecode(local.secret_value), local.generated_env_vars)
  secret_env_vars = [
    for key, value in local.secret_map : {
      name  = key
      value = value
    }
  ]

  tls_secret = jsondecode(data.aws_secretsmanager_secret_version.ecs_tls_certificate.secret_string)

  ecs_tls_env_vars = [
    {
      name  = "SSL_KEY_PEM"
      value = local.tls_secret.private_key
    },
    {
      name  = "SSL_CERT_PEM"
      value = local.tls_secret.certificate
    },
    {
      name  = "SSL_PORT"
      value = "8443"
    }
  ]

  frontend_service_env_vars = concat(local.secret_env_vars, local.ecs_tls_env_vars)
}
