# Read-only product reporting from existing frontend request logs.
module "frontend_page_visits_dashboard" {
  source      = "./modules/frontend_page_visits_dashboard"
  environment = var.environment
  region      = var.region
}

output "frontend_page_visits_dashboard_url" {
  description = "Product dashboard for frontend page visits and session frequency."
  value       = module.frontend_page_visits_dashboard.dashboard_url
}
