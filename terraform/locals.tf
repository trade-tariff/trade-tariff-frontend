locals {
  api_service_backend_url_options = {
    uk = "https://${var.base_domain}/uk/"
    xi = "https://${var.base_domain}/xi"
  }

  # TODO: Revisit this when PaaS is no more
  govuk_app_domain = var.environment != "production" ? var.environment == "development" ? "tariff-frontend-dev" : "tariff-frontend-staging" : "tariff-frontend"
}
