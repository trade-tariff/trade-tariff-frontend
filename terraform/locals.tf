locals {
  api_service_backend_url_options = {
    uk = "http://backend-uk.tariff.internal:8080"
    xi = "http://backend-xi.tariff.internal:8080"
  }

  govuk_app_domain = var.environment != "production" ? var.environment == "development" ? "tariff-frontend-dev" : "tariff-frontend-staging" : "tariff-frontend"
}
